From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
	skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 12:47:36 +0000
Message-ID: <20100823124736.GA16966@ff.dom.local>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg> <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64322 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab0HWMro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 08:47:44 -0400
Received: by fxm13 with SMTP id 13so2854443fxm.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 05:47:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C725FCB.2000304@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 02:47:23PM +0300, Plamen Petrov wrote:
> ???? 21.8.2010 ??. 11:07, Jarek Poplawski ????????????:
>> On Sat, Aug 21, 2010 at 09:50:58AM +0200, Eric Dumazet wrote:
>>> Le samedi 21 ao??t 2010 ?? 09:47 +0200, Jarek Poplawski a =E9crit :
>>>> On Fri, Aug 20, 2010 at 09:38:35PM +0200, Jarek Poplawski wrote:
>>>>> Plamen Petrov wrote, On 20.08.2010 12:53:
>>>>>> So, I guess its David and Herbert's turn?...
>>>>>
>>>>> If you're bored in the meantime I'd suggest to do check the realt=
ek
>>>>> driver eg:
>>>>> - for locking with the patch below,
>>>>> - to turn off with ethtool its tx-checksumming and/or scatter-gat=
her,
=2E..
> Yeah, 3 days and counting, right until I decided to try the freshly
> announced 2.6.36-rc2.
>
> So I upgraded the kernel, but left the scripts that turn GRO off for
> the tg3 card still run at system startup. This way the system ran for
> 2 and a half hours, when I decided its time to try turning GRO on.
>
> I first tried to turn GRO on for the tg3 nic, and the system oopsed
> immediately (if the panic screen is necessary - please, ask for it).
>
> After the system came back, I tried turning GRO on for the 2 RealTek
> 8139 nics, too, but ethtool only accepted turning GRO off.
>
> And unfortunately, I can't test if other nics will fail the same way
> as the motherboard integrated tg3 I have does, so for now, this is
> only a tg3 + GRO on problem; I don't have any other hardware to test
> with available.

A little misunderstanding: I was intersted with turning off some
features on realteks to change the packet path from tg3 with gro
to realtek without gro and without tx-checksumming etc.

But maybe you could try the patch below instead (so the patched
kernel, tg3 with gro on, and realteks without any change).

Thanks,
Jarek P.

--- (for debugging only)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3721fbb..51823cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1935,6 +1935,23 @@ static inline int skb_needs_linearize(struct sk_=
buff *skb,
 					      illegal_highdma(dev, skb))));
 }
=20
+static int skb_csum_start_bug(struct sk_buff *skb)
+{
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
+		long csstart;
+
+		csstart =3D skb->csum_start - skb_headroom(skb);
+		if (WARN_ON(csstart > skb_headlen(skb))) {
+			pr_warning("csum_start %d, headroom %d, headlen %d\n",
+				   skb->csum_start, skb_headroom(skb),
+				   skb_headlen(skb));
+			return 1;
+		}
+	}
+	return 0;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1955,11 +1972,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
 		skb_orphan_try(skb);
=20
 		if (netif_needs_gso(dev, skb)) {
+			skb_csum_start_bug(skb);
 			if (unlikely(dev_gso_segment(skb)))
 				goto out_kfree_skb;
 			if (skb->next)
 				goto gso;
 		} else {
+			skb_csum_start_bug(skb);
 			if (skb_needs_linearize(skb, dev) &&
 			    __skb_linearize(skb))
 				goto out_kfree_skb;
@@ -1997,7 +2016,12 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
-		rc =3D ops->ndo_start_xmit(nskb, dev);
+		if (skb_csum_start_bug(skb)) {
+			kfree_skb(skb);
+			rc =3D NETDEV_TX_OK;
+		} else
+			rc =3D ops->ndo_start_xmit(nskb, dev);
+
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
