From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 13:27:12 +0100
Message-ID: <1482323232.2260.2.camel@stressinduktion.org>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
         <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
         <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
         <20161219.203623.119653805184192345.davem@davemloft.net>
         <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
         <CAM_iQpUgqJEG544HqH1iwdQFL9-nV3-hMuuH_eU9OnJ--pX+jg@mail.gmail.com>
         <20161220221214.w3zerfiy4wu6apee@codemonkey.org.uk>
         <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60292 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752933AbcLUM1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 07:27:19 -0500
In-Reply-To: <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-20 at 22:09 -0800, Cong Wang wrote:
> On Tue, Dec 20, 2016 at 2:12 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
> >         fd = socket(AF_INET6, SOCK_RAW, 7);
> > 
> >         setsockopt(fd, SOL_IPV6, IPV6_CHECKSUM, &zero, 4);
> >         setsockopt(fd, SOL_IPV6, IPV6_DSTOPTS, &buf, LEN);
> > 
> 
> Interesting, you set the checksum offset to be 0, but the packet size
> is actually 49, transport header is located at offset 48, so apparently
> the packet doesn't have room for a 16bit checksum after network header.
> 
> Your original patch seems reasonable to me, unless there is some
> check in __ip6_append_data() which is supposed to catch this, but
> CHECKSUM is specific to raw socket only.

The calculation of total_len is wrong here:

	total_len = inet_sk(sk)->cork.base.length;
	if (offset >= total_len - 1) {
		err = -EINVAL;
		ip6_flush_pending_frames(sk);
		goto out;
	}


At least for this bug to fix we need to subtract the extension header
length after the fragmentation header, so:

--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -536,6 +536,17 @@ static int rawv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
        goto out;
 }
 
+static unsigned int raw6_corked_transport_len(const struct sock *sk)
+{
+       unsigned int len = inet_sk(sk)->cork.base.length;
+       struct ipv6_txoptions *opt = inet6_sk(sk)->cork.opt;
+
+       if (likely(!opt))
+               return len;
+
+       return len - opt->opt_flen;
+}
+
 static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
                                     struct raw6_sock *rp)
 {
@@ -543,7 +554,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
        int err = 0;
        int offset;
        int len;
-       int total_len;
+       int transport_len;
        __wsum tmp_csum;
        __sum16 csum;
 
@@ -555,8 +566,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
                goto out;
 
        offset = rp->offset;
-       total_len = inet_sk(sk)->cork.base.length;
-       if (offset >= total_len - 1) {
+       transport_len = raw6_corked_transport_len(sk);
+       if (offset >= transport_len - 1) {
                err = -EINVAL;
                ip6_flush_pending_frames(sk);
                goto out;
@@ -598,7 +609,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
                tmp_csum = csum_sub(tmp_csum, csum_unfold(csum));
 
        csum = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
-                              total_len, fl6->flowi6_proto, tmp_csum);
+                              transport_len, fl6->flowi6_proto, tmp_csum);
 
        if (csum == 0 && fl6->flowi6_proto == IPPROTO_UDP)
                csum = CSUM_MANGLED_0;
