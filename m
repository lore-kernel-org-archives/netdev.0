From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Wed, 23 Dec 2009 15:09:48 -0800
Message-ID: <4B32A33C.6050507@redfish-solutions.com>
References: <4B298118.2000608@redfish-solutions.com> <200912212150.34727.schmto@hrz.tu-chemnitz.de> <4B2FE882.3080207@redfish-solutions.com> <200912221328.56573.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:56675 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756000AbZLWXJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:09:57 -0500
In-Reply-To: <200912221328.56573.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2009 04:28 AM, Torsten Schmidt wrote:
>> I'll poke around and see if I can figure out how that works...
>>
>> Looking at include/linux/pkt_sched.h:
>>
>> #define TC_PRIO_BESTEFFORT              0
>> #define TC_PRIO_FILLER                  1
>> #define TC_PRIO_BULK                    2
>> #define TC_PRIO_INTERACTIVE_BULK        4
>> #define TC_PRIO_INTERACTIVE             6
>> #define TC_PRIO_CONTROL                 7
>>
>> it seems that these TC priorities are just random, unrelated buckets and
>>  their ordinality has no relation to their priority.  Is that correct?
> No.
>  
> 1.Type Of Service Field is defined in RFC 791:
> Bits 0-2:  Precedence.
> Bit    3:  0 = Normal Delay,      1 = Low Delay.
> Bit    4:  0 = Normal Throughput, 1 = High Throughput.
> Bit    5:  0 = Normal Reliability, 1 = High Reliability.
> Bits 6-7:  ECN (RFC 3168). ECN-ECT, ECN-CE
> 
> 2. include/net/route.h
> static inline char rt_tos2priority(u8 tos)
> {
> 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
> }
> 
> - IPTOS_TOS(tos), masks 0001.1110 
>   (from left: Delay, Throughput, Reliability, ECN-ECT)
> - IPTOS_TOS(tos)>>1, generates: 0000.1111
>   value range: 0 .. 15.
> - ip_tos2prio [ IPTOS_TOS(tos)>>1 ], 
>   lookup table:
> 
> 3. net/ipv4/route.c 
> const __u8 ip_tos2prio[16] = {
> 	TC_PRIO_BESTEFFORT,
> 	ECN_OR_COST(FILLER),
> 	TC_PRIO_BESTEFFORT,
> 	ECN_OR_COST(BESTEFFORT),
> 	TC_PRIO_BULK,
> 	ECN_OR_COST(BULK),
> 	TC_PRIO_BULK,
> 	ECN_OR_COST(BULK),
> 	TC_PRIO_INTERACTIVE,
> 	ECN_OR_COST(INTERACTIVE),
> 	TC_PRIO_INTERACTIVE,
> 	ECN_OR_COST(INTERACTIVE),
> 	TC_PRIO_INTERACTIVE_BULK,
> 	ECN_OR_COST(INTERACTIVE_BULK),
> 	TC_PRIO_INTERACTIVE_BULK,
> 	ECN_OR_COST(INTERACTIVE_BULK)
> };
> 
> with resolved defines it would look like:
> const __u8 ip_tos2prio[16] = {0 1 0 0  2 2 2 2  6 6 6 6  4 4 4 4 };
> 
> So y = rt_tos2priority(x) maps:
> - - - - - - - - - - -
> x	y	bin(x)
> 0	0	0000
> 1	1	0001	-> ECN - ECT bit set
> 2	0	0010	-> High Reliability bit set
> 3	0	0011
> 4	2	0100	-> High Throughput bit set
> 5	2	0101
> 6	2	0110
> 7	2	0111
> 8	6	1000	-> Low Delay bit set
> 9	6	1001
> 10	6	1010
> 11	6	1011
> 12	4	1100
> 13	4	1101
> 14	4	1110
> 15	4	1111
> 
> 4. 
> High Reliability gets priority 0.
> High Throughput gets priority 2.
> Low Delay gets highest priority 6.
> 
> priority:
> -> Low Delay (6), High Throughput (2), High Reliability (0) !
> 
> 5.
>> If that's the case, then you *can't* just do:
>> static inline char rt_dscp2priority(u8 tos)
>> {
>> 	return IPTOS_PREC(tos)>>5;
>> }
>>
>> for instance.  No, that would be too easy.  :-)
> No, thats right. You map:
> 
> y = rt_dscp2priority(x)
> y	x
> - - - - - - - -
> 0	CS0
> 1	CS1
> 2	CS2
> 3	CS3
> 4	CS4
> 5	CS5
> 6	CS6
> 7	CS7
> 
> This IMHO is compliant to RFC 2474. 
> 
> 6. So we simply need to do:
> static inline char rt_tos2priority(u8 tos)
> {
> #ifdef CONFIG_IP_DIFFSERV_COMPLIANT
> 	return tos >> 5;
> #else
> 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
> #endif
> }
> 
> 7. -> See [PATCH]: ipv4: add DiffServ priority based routing
>     
>     Enables IPv4 Differentiated Services support for IP priority based
>     routing. Notice that the IP TOS field was redefined 1998 to DiffServ
>     (RFC 2474). Type Of Service is deprecated since 1998 !
>     
>     This patch adds a compliant flag to net/ipv4/Kconfig, which allows
>     the user to select DiffServ ore TOS priority based routing. Default
>     answer is TOS.
>     
>     Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
> 
> 
> Torsten
> 
> 


Can you extend the patch to include classify_1d() in net/mac80211/wme.c?

I'm thinking:

         }

-        if (dscp & 0x1c)
+#if !defined(CONFIG_IP_DIFFSERV_COMPLIANT)
+        if (IPTOS_TOS(dscp) & ~IPTOS_LOWCOST)
                 return 0;
+#endif
         return dscp >> 5;
 }


should do it.

-Philip

