From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2/nstat: Bug in displaying icmp stats
Date: Fri, 05 Dec 2014 17:13:50 -0800
Message-ID: <1417828430.15618.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGK4HS_ty2=f0PNU-w8QPP9BoP67E+4MaDxLTLV4G22dx_7A-Q@mail.gmail.com>
	 <1417828247.15618.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:46020 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaLFBNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 20:13:52 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so1777576iec.29
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 17:13:51 -0800 (PST)
In-Reply-To: <1417828247.15618.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 17:10 -0800, Eric Dumazet wrote:
> On Fri, 2014-12-05 at 15:35 -0800, Vijay Subramanian wrote:
> > Hi,
> > 
> > I noticed nstat is displaying icmp stats incorrectly.
> > 
> > $ cat /proc/net/snmp | grep Icmp | head -2 | awk '{print $1 " " $2 " "
> > $3 " " $4}'
> > Icmp: InMsgs InErrors InCsumErrors
> > Icmp: 215 0 0
> > 
> > $ nstat  -az | grep IcmpIn  | head -3
> > IcmpInMsgs                      0                  0.0
> > IcmpInErrors                    215                0.0
> > IcmpInCsumErrors                0                  0.0
> > 
> > For example, as seen in /proc/net/snmp, IcmpInMsgs should be 215 but
> > that value is assigned to IcmpInErrors.
> > 
> > The issue seems to be the way the values are populated.
> > 
> > $vim +209 misc/nstat.c
> > -----x----
> > 
> >                        /* Trick to skip "dummy" trailing ICMP MIB in 2.4 */
> > 
> >                         if (strcmp(idbuf, "IcmpOutAddrMaskReps") == 0)
> > 
> >                                 idbuf[5] = 0;
> > 
> >                         else
> > 
> >                                 n = n->next;
> > 
> > -----x------
> > 
> > It seems "IcmpOutAddrMaskReps" is processed twice and values assigned
> > are off by one.
> > 
> > Any idea what the code is doing for 2.4 kernel and how to fix this?
> > 
> > vijay
> 
> According to
> git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
> 
> This was fixed in 2002 :
> 
> commit b838c6d5c189d03d3db56c2774de451cf041a39f
> Author: Erik Schoenfelder <schoenfr@gaaertner.de>
> Date:   Sun Sep 29 03:56:52 2002 -0700
> 
>     net/ipv4/proc.c: Dont print dummy member of icmp_mib.
> 
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index 649620a..3f2dbcb 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -128,7 +128,7 @@ int snmp_get_info(char *buffer, char **start, off_t offset, int length)
>         len += sprintf (buffer + len,
>                 "\nIcmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps OutTimestampReps OutAddrMasks OutAddrMaskReps\n"
>                   "Icmp:");
> -       for (i=0; i<offsetof(struct icmp_mib, __pad)/sizeof(unsigned long); i++)
> +       for (i=0; i<offsetof(struct icmp_mib, dummy)/sizeof(unsigned long); i++)
>                 len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)icmp_statistics, sizeof(struct icmp_mib), i));
>  
>         len += sprintf (buffer + len,
> 

I guess we could count number of spaces/fields in both lines,
and disable the iproute2 trick if counts match.
