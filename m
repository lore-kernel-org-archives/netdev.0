From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Show more info (ring,fanout) for packet
 socks
Date: Thu, 14 May 2015 23:21:43 +0300
Message-ID: <20150514202143.GA22330@angus-think.lan>
References: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
 <CA+FuTSeM_FQBRToXCBix9ns3_07ivfqxYHB4nGHcSqqp31fX5A@mail.gmail.com>
 <20150514110900.GA28582@angus-think.wlc.globallogic.com>
 <CA+FuTSditeDHFKD-NLUJsZ=Cgyzca3RZysecRAx=whzpg+E6cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36822 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161099AbbENUWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 16:22:25 -0400
Received: by wgbhc8 with SMTP id hc8so54365180wgb.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 13:22:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+FuTSditeDHFKD-NLUJsZ=Cgyzca3RZysecRAx=whzpg+E6cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 03:54:41PM -0400, Willem de Bruijn wrote:
> On Thu, May 14, 2015 at 7:09 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > On Wed, May 13, 2015 at 05:10:38PM -0400, Willem de Bruijn wrote:
> >> > +               }
> >> > +               if (has_fanout) {
> >> > +                       uint16_t type = (fanout >> 16) & 0xffff;
> >>
> >> type can be modified by flags in the upper 8 bits. Better
> >> mask those out and report them separately.
> > Kernel puts only id & type in diag message, flags are stored in separated
> > member of 'struct packet_sock'.
> 
> I don't mean pdi_flags, but
> 
>   PACKET_FANOUT_FLAG_ROLLOVER
>   PACKET_FANOUT_FLAG_DEFRAG
sure, I understood what you meant.
> 
> which are passed as part of this u32 by the process during setsockopt
> PACKET_FANOUT.
> 
OK, its better to look into the kernel:

net/packet/af_packet.c

static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
{
	struct packet_fanout *f, *match;
	u8 type = type_flags & 0xff;
	u8 flags = type_flags >> 8;

	...

	match->id = id;
	match->type = type;
	match->flags = flags;

	...
}

As I see this function is called from setsockopt, takes type_flags and splits it into type & flags
and store them separately in struct packet_fanout.

Then what I see in:

net/packet/diag.c:


static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
{
	int ret = 0;

	mutex_lock(&fanout_mutex);
	if (po->fanout) {
		u32 val;

		val = (u32)po->fanout->id | ((u32)po->fanout->type << 16);
		ret = nla_put_u32(nlskb, PACKET_DIAG_FANOUT, val);
	}
	mutex_unlock(&fanout_mutex);

	return ret;
}

I see that to put flags here it needs to use po->fanout->flags and mix
them into u32 val, but instead I see that it uses only id & type.

Please correct me if I am wrong.

Thanks,
> >
> >>
> >> > +
> >> > +                       printf("\n\tfanout(");
> >> > +                       printf("id:%d,", fanout & 0xff);
> >> > +                       printf("type:0x%x", type);
> >> > +                       if (type == 0)
> >> > +                               printf("(hash)");
> >> > +                       else if (type == 1)
> >> > +                               printf("(lb)");
> >> > +                       else if (type == 2)
> >> > +                               printf("(cpu)");
> >> > +                       else if (type == 3)
> >> > +                               printf("(rollover)");
> >> > +                       else if (type == 4)
> >> > +                               printf("(random)");
> >> > +                       else if (type == 5)
> >> > +                               printf("(qm)");
