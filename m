From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Tue, 12 Apr 2005 19:45:34 -0700
Message-ID: <OF0A4F590E.3F5A449F-ON88256FE2.000E49F8-88256FE2.000F289A@us.ibm.com>
References: <20050413.095308.124546011.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050413.095308.124546011.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/12/2005 
05:53:08 PM:

> Please geive up the "singed-off" line.


> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

:-)

> Anyway, how about this?

csum has to be a pointer into the packet data, so it can store
the checksum it computes for the outgoing packet at that (user-provided)
offset. It looks like skb_header_pointer gives a copy of the
existing value, pointing to csum_buff, which wouldn't modify the
packet value, right? So, I don't think that'll work.

Something that would follow the skbuffs to that offset would
be good, rather than doing it in-line, but I don't know of an
existing function that does that (looked briefly, without
success). If there is one, or it'd be used more than once, then
"skb_offset_pointer" or some such that does the skb & nr_frags
loop could be used here, as long as the end result is a pointer
to the packet data and not, unless I'm wrong, a pointer to a copy
of the packet data in a different buffer.

                                                +-DLS

> ===== net/ipv6/raw.c 1.80 vs edited =====
> --- 1.80/net/ipv6/raw.c 2005-03-27 08:04:35 +09:00
> +++ edited/net/ipv6/raw.c 2005-04-13 09:49:37 +09:00
> @@ -456,7 +456,7 @@
> {
> struct sk_buff *skb;
> int err = 0;
> - u16 *csum;
> + u16 csum_buff, *csum;
> u32 tmp_csum;

> if (!rp->checksum)
> @@ -465,12 +465,13 @@
> if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
> goto out;
> 
> - if (rp->offset + 1 < len)
> -  csum = (u16 *)(skb->h.raw + rp->offset);
> - else {
> -  err = -EINVAL;
> + err = -EINVAL;
> + if (rp->offset + 1 >= len)
> +  goto out;
> +
> + csum = skb_header_pointer(skb, skb->h.raw - skb->data + rp->offset, 
> sizeof(csum_buff), &csum_buff);
> + if (!csum)
> goto out;
> - }

> /* should be check HW csum miyazawa */
> if (skb_queue_len(&sk->sk_write_queue) == 1) {
> 
> --
> Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
> Homepage: http://www.yoshifuji.org/~hideaki/
> GPG FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
