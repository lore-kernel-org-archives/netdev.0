From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: [PATCH 3/7] net: replace NIPQUAD() in net/netfilter/
Date: Mon, 3 Nov 2008 23:52:02 +0100
Message-ID: <43ca39800811031452x20702fc9i3151a7beb8a928e4@mail.gmail.com>
References: <1225412025.5574.34.camel@brick>
	 <43ca39800811030856u5acf9601s6aef81887f19f859@mail.gmail.com>
	 <1225734196.5361.5.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:62738 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbYKCWwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 17:52:04 -0500
Received: by an-out-0708.google.com with SMTP id d40so138809and.1
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 14:52:03 -0800 (PST)
In-Reply-To: <1225734196.5361.5.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Nov 3, 2008 at 6:43 PM, Harvey Harrison
<harvey.harrison@gmail.com> wrote:
> On Mon, 2008-11-03 at 17:56 +0100, Julius Volz wrote:
>> Hi,
>> I just noticed that this breaks IPv4 addresses in IPVS debug output
>> (didn't check in other places). It seems that during integer to ASCII
>> conversion, the converted digits are output the wrong way around (not
>> endianness though). For example, 10.0.0.254 is output as 01.0.0.452.
>> Could something be wrong with ip4_addr_string() or put_dec_trunc() in
>> lib/vsprintf.c?
>
> Mea Culpa, I was testing with a too-simple case, it does reverse the digits,
> can you try this:
>
> From: Harvey Harrison <harvey.harrison@gmail.com>
> [PATCH] printk: ipv4 address digits printed in reverse order
>
> put_dec_trunc prints the digits in reverse order and is reversed
> inside number(). Continue using put_dec_trunc, but reverse each quad
> in ip4_addr_string.
>
> [Noticed by Julius Volz]
>
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  lib/vsprintf.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index dd7cc7f..6897724 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -620,11 +620,15 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr, int field_width,
>                         int precision, int flags)
>  {
>        char ip4_addr[4 * 4]; /* (4 * 3 decimal digits), 3 dots and trailing zero */
> +       char temp[3];   /* hold each IP quad in reverse order */
>        char *p = ip4_addr;
> -       int i;
> +       int i, digits;
>
>        for (i = 0; i < 4; i++) {
> -               p = put_dec_trunc(p, addr[i]);
> +               digits = put_dec_trunc(temp, addr[i]) - temp;
> +               /* reverse the digits in the quad */
> +               while (digits--)
> +                       *p++ = temp[digits];
>                if (i != 3)
>                        *p++ = '.';
>        }
> --
> 1.6.0.3.756.gb776d

Yes, that does the trick! Thanks!

Julius
