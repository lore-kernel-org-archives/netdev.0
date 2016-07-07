From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Resurrecting due to huge ipoib perf regression - [BUG] skb corruption
 and kernel panic at forwarding with fragmentation
Date: Wed, 6 Jul 2016 23:25:57 -0700
Message-ID: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 7, 2016 at 3:00 AM, Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Or just shift GSO CB and add couple checks like
> BUILD_BUG_ON(sizeof(SKB_GSO_CB(skb)->room) < sizeof(*IPCB(skb)));

Resurrecting this old thread, because the patch that ultimately went
upstream (commit 9207f9d45b0a / net: preserve IP control block during
GSO segmentation) causes a huge IPoIB performance regression (to the
point of being unusable):
https://bugzilla.kernel.org/show_bug.cgi?id=111921

I don't think anyone has explained what goes wrong or why IPoIB works
the way it does.  The underlying difference that IPoIB has from other
drivers is that there are two levels of address resolution.  First,
normal ARP / ND resolves an IP address to a "hardware" address.  The
difference is that in IPoIB, the hardware address is an IB GID (plus a
QPN, but we can ignore that).  To actually send data to that GID, the
IPoIB driver has to do a second lookup - it needs to ask the IB subnet
manager for a path record that tells it how to reach that GID.

In particular this means that "destination address" (as the IP / ARP
layer understands it) actually isn't in the packet anywhere - there's
nothing like an ethernet header as there is for "normal" network
drivers.  Instead, the driver stashes the address in skb->cb during
hard_header_ops->create() and then looks at it in the xmit routine -
this was designed way back around when commit a0417fa3a18a / net: Make
qdisc_skb_cb upper size bound explicit. was merged.  The expectation
was that the part of the cb after sizeof (struct qdisc_skb_cb) would
be preserved.

The problem with commit 9207f9d45b0a is that GSO operations now access
cb after SKB_SGO_CB_OFFSET==32, which lands right in the middle of
where IPoIB stashes its hwaddr.

It seems that the intent of the commit is to preserve the IP control
block - struct inet_skb_parm (and presumably struct inet6_skb_parm) -
even when using SKB_GSO_CB().  Seems like both inet_skb_parm and
inet6_skb_parm are 20 bytes.  IPoIB uses the part of cb after 28
bytes, so if we could squeeze struct skb_gso_cb down to 8 bytes and
set SKB_SGO_CB_OFFSET to 20, then everything would work.  The struct
is

struct skb_gso_cb {
        int     mac_offset;
        int     encap_level;
        __u16   csum_start;
};

is it feasible to make encap_level a __u16 (which would make the
overall struct exactly 8 bytes)?  If I understand this correctly, 64K
nested encapsulations seems like quite a bit for a packet...

Or, earlier in this thread, having the GSO in ip_output and other gso
paths save and restore the IP/IP6 control block was suggested as an
alternate approach.  I don't know if there are performance
implications to that.

What is the best way to keep the crash fix but not kill IPoIB performance?

Thanks!
 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
