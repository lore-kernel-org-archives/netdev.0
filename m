From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net/sched/em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Tue, 12 Jun 2012 16:33:13 +0200
Message-ID: <1339511593.22704.157.camel@edumazet-glaptop>
References: <1339508913-7784-1-git-send-email-lisovy@gmail.com>
	 <1339509809.22704.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1339509809.22704.149.camel@edumazet-glaptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-06-12 at 16:03 +0200, Eric Dumazet wrote:
> On Tue, 2012-06-12 at 15:48 +0200, Rostislav Lisovy wrote:
> > em_canid is an ematch capable of classifying CAN frames according to
> > their CAN IDs.
> > 
> > This RFC/Patch contains a reworked classifier initially posted in
> > http://www.spinics.net/lists/netdev/msg200114.html
> > The functionality is the same however there is almost 50% reduction
> > in the source code length.
> > 
> > There is a slight difference between this ematch and other available
> > ematches. Other ematches implement only a simple match operation and
> > are meant to be combined with logic conjunctions (e.g. AND, OR).
> > Our ematch makes it possible to use up to 32 rules in single
> > 'configuration statement' (with OR semantics). This allows us to take
> > the advantage of the bit field data-structure in the implementation of
> > the match function.
> > 
> > Example: canid(sff 0x123 eff 0x124 sff 0x230:0x7f0)
> > This ematch would match CAN SFF frames with the following IDs:
> > 0x123, 0x230--0x23f or EFF frame with ID 0x124.
> > 
> > Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
> > ---
> >  include/linux/can.h     |    3 +
> >  include/linux/pkt_cls.h |    5 +-
> >  net/sched/Kconfig       |   10 +++
> >  net/sched/Makefile      |    1 +
> >  net/sched/em_canid.c    |  217 +++++++++++++++++++++++++++++++++++++++++++++++
> >  5 files changed, 234 insertions(+), 2 deletions(-)
> >  create mode 100644 net/sched/em_canid.c
> > 
> > diff --git a/include/linux/can.h b/include/linux/can.h
> > index 9a19bcb..08d1610 100644
> > --- a/include/linux/can.h
> > +++ b/include/linux/can.h
> > @@ -38,6 +38,9 @@
> >   */
> >  typedef __u32 canid_t;
> >  
> > +#define CAN_SFF_ID_BITS		11
> > +#define CAN_EFF_ID_BITS		29
> > +
> 
> > +struct canid_match {
> > +	struct can_filter rules_raw[EM_CAN_RULES_SIZE]; /* Raw rules copied
> > +		from netlink message; Used for sending information to
> > +		userspace (when 'tc filter show' is invoked) AND when
> > +		matching EFF frames*/
> > +	DECLARE_BITMAP(match_sff, (1 << CAN_SFF_ID_BITS)); /* For each SFF CAN
> > +		ID (11 bit) there is one record in this	bitfield */
> > +	int rules_count;
> > +	int eff_rules_count;
> > +	int sff_rules_count;
> > +
> > +	struct rcu_head rcu;
> > +};
> 
> The size of kmalloc() blob to hold this structure is 4 Mbytes
> 
> This is a huge cost, and unlikely to succeed but shortly after boot...
> 
> (this happens to be the largest possible kmalloc() allocation by the way
> on x86)
> 
> 

Oh well, I mixed CAN_SFF_ID_BITS / CAN_EFF_ID_BITS



