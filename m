From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Wed, 2 Sep 2015 20:35:53 +0900
Message-ID: <20150902113553.GA3282@gmail.com>
References: <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150817.140222.1763422851882964859.davem@davemloft.net>
 <55D492CC.6010602@iogearbox.net>
 <20150902000400.GA14821@gmail.com>
 <55E6C5AE.4060308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34498 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbbIBLf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 07:35:59 -0400
Received: by padhy1 with SMTP id hy1so9145252pad.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 04:35:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55E6C5AE.4060308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for the reply.

On Wed, Sep 02, 2015 at 11:47:26AM +0200, Daniel Borkmann wrote:
> On 09/02/2015 02:04 AM, Ken-ichirou MATSUZAWA wrote:
> >Talking about skb_copy path, original skb's shared info is accessed
> >only in copy_skb_header, to get gso related field. As a result of
> 
> It's still not correct. The thing is you can neither call skb_copy() nor
> skb_clone() on netlink mmaped skbs. For example, skb_copy_bits() would

I am sorry for the lack of explanation.
And I am afraid I misunderstand...

Updated pointers to its data area in a mmaped netlink skb is only
its tail. Head, data and end will not be updated. skb_copy() calls

    int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)

as its argument, "offset" is always 0 and "len" is skb->len. In
skb_copy_bits() both "start" and "copy" are skb->len, which means
"len - copy" is always 0 so that retuns 0 before accessing shared
info.

I don't know the situation is intended or not, it seems that
skb_copy() for a mmaped skb will not access its shared info.

After that, copy_skb_header() will set newly allocate skb's (wrong)
gso fields, I asked we should clear it or not.

> special case. We need an own netlink_mmap_to_full_skb() handler for this,
> that copies/transforms this into a "normal" skb. I'll have a look it this

If the above situation is an unintentional, we need it to avoid a
future confusion.

Thanks,
