From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] netfilter: prevent harmless integer overflow
Date: Thu, 20 Jun 2013 14:09:44 +0300
Message-ID: <20130620110944.GS5008@mwanda>
References: <20130618074603.GF12329@elgon.mountain>
	<20130620102352.GA19813@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>, netfilter@vger.kernel.org,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130620102352.GA19813@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 20, 2013 at 12:23:52PM +0200, Pablo Neira Ayuso wrote:
> On Tue, Jun 18, 2013 at 10:46:03AM +0300, Dan Carpenter wrote:
> > This overflow is harmless because a few lines later we check:
> > 
> > 	if (num_counters != t->private->nentries) {
> > 
> > But it still upsets the static checkers.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> > index 3d110c4..141350e 100644
> > --- a/net/bridge/netfilter/ebtables.c
> > +++ b/net/bridge/netfilter/ebtables.c
> > @@ -1278,6 +1278,8 @@ static int do_update_counters(struct net *net, const char *name,
> >  
> >  	if (num_counters == 0)
> >  		return -EINVAL;
> > +	if (num_counters > INT_MAX / sizeof(*tmp))
> > +		return -ENOMEM;
> 
> This is artificially limiting to INT_MAX / sizeof(struct counters).
> Before this patch, the limit is UINT_MAX / sizeof(struct counters). I
> think it's very unlikely to hit such a limit though, but as you
> mentioned we cover the overflow already.  Adding it to calm down a
> static checker sound a bit too much for me.

I think we may be talking about different things?

"num_counters" comes from the user in update_counters() and we can
definitely overflow.  I just copied the checks from do_replace() so
that's why it uses INT_MAX instead of UINT_MAX.

Like I said, the overflow is not harmful because later in the
function we check "(num_counters != t->private->nentries)" and
return an error before using "tmp".  So I don't feel strongly about
this patch either way.

regards,
dan carpenter
