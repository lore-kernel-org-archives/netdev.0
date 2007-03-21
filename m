From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Wed, 21 Mar 2007 13:01:59 +0100 (CET)
Message-ID: <Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="497817361-118116108-1174478519=:534"
Cc: "irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:55731 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbXCUMCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 08:02:04 -0400
In-Reply-To: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--497817361-118116108-1174478519=:534
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Wed, 21 Mar 2007, Samuel Ortiz wrote:

> On 3/21/2007, "Guennadi Liakhovetski" <gl@dsa-ac.de> wrote:
>
>> [<c0182380>] (__kfree_skb+0x0/0x170) from [<c0182514>] (kfree_skb+0x24/0x50)
>>  r5 = C332BC00  r4 = C332BC00
>> [<c01824f0>] (kfree_skb+0x0/0x50) from [<bf0fac58>] (irlap_update_nr_received+0x94/0xc8 [irda])
>> [<bf0fabc4>] (irlap_update_nr_received+0x0/0xc8 [irda]) from [<bf0fda98>] (irlap_state_nrm_p+0x530/0x7c0 [irda])
>>  r7 = 00000001  r6 = C0367EC0  r5 = C332BC00  r4 = 00000000
>> [<bf0fd568>] (irlap_state_nrm_p+0x0/0x7c0 [irda]) from [<bf0fbd90>] (irlap_do_event+0x68/0x18c [irda])
>> [<bf0fbd28>] (irlap_do_event+0x0/0x18c [irda]) from [<bf1008cc>] (irlap_driver_rcv+0x1f0/0xd38 [irda])
>> [<bf1006dc>] (irlap_driver_rcv+0x0/0xd38 [irda]) from [<c01892c0>] (netif_receive_skb+0x244/0x338)
>> [<c018907c>] (netif_receive_skb+0x0/0x338) from [<c0189468>] (process_backlog+0xb4/0x194)
>> [<c01893b4>] (process_backlog+0x0/0x194) from [<c01895f8>] (net_rx_action+0xb0/0x210)
>> [<c0189548>] (net_rx_action+0x0/0x210) from [<c0042f7c>] (ksoftirqd+0x108/0x1cc)
>> [<c0042e74>] (ksoftirqd+0x0/0x1cc) from [<c0053614>] (kthread+0x10c/0x138)
>> [<c0053508>] (kthread+0x0/0x138) from [<c003f918>] (do_exit+0x0/0x8b0)
>>  r8 = 00000000  r7 = 00000000  r6 = 00000000  r5 = 00000000
>>  r4 = 00000000
> This is the IrDA RX path, so I doubt the corresponding skb ever got
> through
> ip_append_data(). The skb was allocated by your HW driver upon packet
> reception, then queued to the net input queue, and finally passed to the
> IrDA stack. Are you sure your tracing is correct ?

I've added a bitfield to struct sk_buff:

  	__u8			pkt_type:3,
  				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				trace_dbg:1;

and I set itin ip_append_data() before sock_alloc_send_skb() is called. 
Then I check this bit in __kfree_skb(). The bit is set to 0 in __alloc_skb 
per

 	memset(skb, 0, offsetof(struct sk_buff, truesize));

So, if it was a freshly allocated skb, the tracing should be correct.

>> [<c0182380>] (__kfree_skb+0x0/0x170) from [<c0182514>] (kfree_skb+0x24/0x50)
>>  r5 = C03909E0  r4 = C1A97400
>> [<c01824f0>] (kfree_skb+0x0/0x50) from [<c0199bf8>] (pfifo_fast_enqueue+0xb4/0xd0)
>> [<c0199b44>] (pfifo_fast_enqueue+0x0/0xd0) from [<c0188c30>] (dev_queue_xmit+0x17c/0x25c)
>>  r8 = C1A2DCE0  r7 = FFFFFFF4  r6 = C3393114  r5 = C03909E0
>>  r4 = C3393000
>> [<c0188ab4>] (dev_queue_xmit+0x0/0x25c) from [<c01a7c18>] (ip_output+0x150/0x254)
>>  r7 = C3717120  r6 = C03909E0  r5 = 00000000  r4 = C1A2DCE0
>> [<c01a7ac8>] (ip_output+0x0/0x254) from [<c01a93d0>] (ip_push_pending_frames+0x368/0x4d4)
>> [<c01a9068>] (ip_push_pending_frames+0x0/0x4d4) from [<c01c6954>] (udp_push_pending_frames+0x14c/0x310)
>> [<c01c6808>] (udp_push_pending_frames+0x0/0x310) from [<c01c70d8>] (udp_sendmsg+0x5c0/0x690)
>> [<c01c6b18>] (udp_sendmsg+0x0/0x690) from [<c01ceafc>] (inet_sendmsg+0x60/0x64)
>> [<c01cea9c>] (inet_sendmsg+0x0/0x64) from [<c017c970>] (sock_sendmsg+0xb4/0xe4)
>>  r7 = C2CEFDF4  r6 = 00000064  r5 = C2CEFEA8  r4 = C3C94080
>> [<c017c8bc>] (sock_sendmsg+0x0/0xe4) from [<c017dd9c>] (sys_sendto+0xc8/0xf0)
>>  r7 = 00000064  r6 = C3571580  r5 = C2CEFEC4  r4 = 00000000
>> [<c017dcd4>] (sys_sendto+0x0/0xf0) from [<c017e654>] (sys_socketcall+0x168/0x1f0)
>> [<c017e4ec>] (sys_socketcall+0x0/0x1f0) from [<c001ff40>] (ret_fast_syscall+0x0/0x2c)
>>  r5 = 00415344  r4 = 00000000
> This one is on the TX path, yes. However it got dropped and freed because
> your TX queue was full. Any idea in which situation does that happen ?

No. I can only describe what communication is running while ppp is 
disrupted - it's just some sort of udp mirror test - udp packets are sent 
one after another and mirrored back.

>> I would be greatful for any hints how I can identify which skbuff's get
>> lost and why, and where and who should free them.
> You're seeing skb leaks when cutting the ppp connection periodically,
> right ?

Right

> Do you such leaks when not cutting the ppp connection ?

Looks like I don't.

> If not, could you send me a kernel trace (with irda debug set to 5) when
> the ppp connection is shut down ? It would narrow down the problem a bit.

Attached bzipped... It's a complete log starting from irda up, running udp 
packets over the link, closing the link and bringing irda completely down.

> I'm quite sure the leak is in the IrDA code rather than in the ppp or
> ipv4 one, hence the need for full irda debug...

Likely, yes. Why I am asking netdev guys for help is just because I have 
very little idea about the data flow in the network stack(s). And the more 
experienced eyes we have on the problem the sooner we might solve it, I 
hope...

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
--497817361-118116108-1174478519=:534
Content-Type: APPLICATION/octet-stream; name=mpppdown.bz2
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.63.0703211301590.534@pcgl.dsa-ac.de>
Content-Description: 
Content-Disposition: attachment; filename=mpppdown.bz2

QlpoOTFBWSZTWYSBtXIB2KhfgFQQYWf/938v//q////wYEu/QX0vrT5PuQQv
dVe+e9ugADAPjQ+vfB0AVKlRVChKlSoiXAOvPjA93gYBwIAA99x9c9t6WeHf
HAvvd986+M8axg2tZ3A+8+rnyBI7b6B33AAbXu8G+93eYfS2Hez0FPe8H16P
gc19659eSXQ0RWxu97wCKtPXbdBkAHQCjRyDuwAAGgEBKFOgB3OuADoHr0B2
eOOgAUASJAjTIIp6ieiMkaGmnqZDNQA9QDRkNAkkwNVKTUQaaaDQGhoGgAAA
AAEQlKEyRqTI0GgDJpk9IA0AAAACT1VCImmUmj1M1DTQBoAAAAAAATVKmTTe
qhSnmqbSeoGgyADCaB6jIyGIZAFKSCCaCaBAQ1T2hNU/TJTyn5JpppM0NTTN
E085I9mL/fkI8k98/xwbfu1rE2yvG1qbR/hx4iGRrBTx7pfBW8vsZSvvza/v
ofF9nqOHFn66th4ykve+WpyhcI0vQWuuxmPZveUUtKlCW8a/piHnAQ3IfM+K
TFx9MBowow9rdInrb65gGrUx0mFJLoaDz7w2kYGI+w+YuShUDy7NzhtWSUE8
SkSOnAsQEBqWCFH0EdJrpD1lFENDs8a9htVxGE2tzDK7Dt5+MZppg9Q5Hqrg
9jscFmVkzz3quE4MRv14NDF1Hb2785mTMXVVxV1jZd67VbDMzGYZc91snSYr
vOJk6zq6WZmZOlOC6nC7XouFYs83ns4jhmteO3bZbtt4+IBBt31Vzrd9uZ2e
hwMM7WU6WSuzkyel67yzMzMYxcwbU5Nq6rom1MXOues0WlkrueTF2u/WZmZZ
mZmToOC6nE7npOEyZmdrI6WFdz2z5uq8HOr29pJJJIfGy/IEKD4mQ+F9l9on
IxfhaL6yDEDg5Is9V9ST5SEkA9BHB0cV2dRwsyYd+MmR0ZS7XKw9HruzMyzM
zKug4jqcLs9RxLDJqY5FAsFAg4VogVo7YiCCCEsBKaczZdV0ptTFw6rZNLKu
q3WHRdeuYzMz8sOkW62ydFvOy6ptTDbsSBoQCaLCA0HsQogMQnAFAaFAw4CU
oC7aoCVCQ1YQi0+iIiCEYkEpYpXLUEgQiOCEsCBHKlC0N6IiIWJKUsCVwaBI
oVcSjCEHBYQrN6IiIDEBIYSuNFKUK74KESEJLk4MXB165mZmZmYuSto5Nl1O
ibJizqsLmslt066MnWup48tTqjcus2u8752pusZZZsYOTJdjeYdDp3zGZmZO
ZNhybHU6DYYZ1w5w6t4N7ogxBKyTjQlQXXJFIRKRCAODdqza8Nrv4gAkErd6
tuda7lwXcvUXEWFnOZ2niTpMqXdbtrNbtW8fGQAkAkrd7VXCnVOI7T1JwTE5
59evPnO4yju2a1c9dtXk5rLbxtvHsgJN5efHJg2qr11Rscp7xzcYpkZmYWS+
dcfL4rEnB4JQP04lGD8fd/Pu+c6fhiNxbCYsirs22/icNtiqg2ErMQVEpIml
uB5SKw1rXl9X9GlhNJ0rxa1uNBaK7CArTm32GwgRH1FXd11VVVVVVVVWBcGR
9pIFHguV5vN5PN7rsunTp07Ozs7OzsunTp07FNoQvHnizUm+oDDEJz0lLbjj
ieTW1LeUmybUTwPSUH6cnpiOVsVIy+kshh4gTZsw8toXqngzHXq1t1xvinet
WvS+HsbjNw3INzcqZZsogOeLSA+pilOMvFcGIxj4PGgfC1vsnBzylCOrQu0Q
W7UzMO+8LqfR1FOsW1787U4rVrd8vY3GbhuQbm5UyzZRC3rAHDFLvBtTY2jb
bv20DhrMA4OOAIFzWF1EFuqYmHbzwup9HUddZtfvtOc2svl6mBmAwQYMFToZ
0EQHfi0gOmKU4y8VwYjGO/fQNWsx5nEjnlKEdWhdogt2pmYd4hdR0dR11i2v
e85zaw+HqYGYDBBgwVORnIRCDesAcMUu8UbhG1djaNtu/a4cMGrwccJQjmsL
qILdUxMO3ELmcjmOecW17XnObWHw+1zIzIZIMmSxYZyE4R1UgRuzlnoYunV8
O+5qbhuQYNzv31XZ/heGbx4fHang8yUC1vEMIas34jxTzdTW3l4n4PEePGl2
XfA5DPUwsMKNAsshpZwUMBggwYLfCyu8G4MMbwGH4fqcmkgMtCD435Y6iS+Z
H9vrhehdwh5GxjigwQRgMEFGCIgxGCMQQGKJCIijIBSFIRGIiCCINEEYIKAK
ICMEUBBIYKDBERFEEERggiKCCKDJEUQQBiCCIoi4r09nG/vtb6TWWZMxmBmF
P5fuoj/Ta/Zev4dvjxrqpIzf1RGvKz/zCOGz7cZpQm+xI1+Lrp/66Zzra9oC
qYumSdspDWSAfX9uNJp+1AvTxn8SAASSIp19x6N7mlYLSHLXdv/Ttseub41m
bSZ0bs/AiOqIwlU+Xk++KHx8KSN3KWikdyrvhKtRvjPx1bFVftuRSMhgkvyl
U1EmwBfj8uzxnsjb19/a3XBgVecvF/Ygs8FLAfG+PGS4cywWYqVfOZSBzv12
4GKo8mSoxGQPrIgie+g+v4H7D9r8k+5m/ksh9+HaH7MxszuaZ70n3I9t1p0Z
03CQijtPvJary8mEHme9u73aRu7u6U8LjMmSICWiIuih4acxjYzhtw1rv05I
EgSgKQgUlC8LpCdC2GsMaMMEPz4XCNQxYptUUsNWmJmJoyglGgqApBomlyvS
1abNWza1tbbWza3S1NiYkxCXLtRuIxoxoxizAei0RiOFSlqilpq0xMxNEaJp
ypabTaxhYmp3cyTAwrESgmIECzRVPj2Vht5CQjDMMSxUlMOjzsxs5sbYxsrM
PZhmMbY2xjZWYezDMY2xtjGysw9mGYxtjbGNlZh7MMxjbG2MbKzD2YZjG2Ns
Y2VmHswzGNsbYxsrMPZhmMbY2xjZSVET2ZN367uqqqsJv2xvVmevIzKz1Uza
wife9Um5N1tegPANK0al3PU7NNNmza1tbbWm1u5itSYkwK92W6HnszI9ylKh
cjkrFwmlyabNra1a1s1bW2lqbGziuKuGZXC01atW1abNm1ra22mkwbSGhMSY
psuy2PjNMzjsuXUmK6PK01el2tNNmza1tbbWmg2IaE0JivvCGgF1cd3GHGmm
GGcNvx6n28iEigXIOEsQuQmJcIam01W1bVs00tmq1otJtCaFtz25Zd3chKJC
QsK0PJWLUMWnc1W1q2bNWtbWrW1ttNpqbOJwXEcS2NTabTU2ml3ssNVs02Wq
1WtFsmybSrhHcjwu7KrvevT2WdrG2NsY2UUUVzVytNWrVpp3qxbWtrba0YNp
DBMSYpL6IzoiIiCMmpqw1IwHpWx2nSbGy1NLZabVs00tmy1sWk0WpxODicLT
Zs02rTZtbWrWtmra20tpsbPGbLMlmSzJZkszHnuzzvfG+Hg1rAGGpaGpYGJY
MODyNDAsMRAOS6l2nSbTY7lqaWy1W1bNNLZtW1sWybU2OJcSuCuBtLaWlals
zJbK71VkamlqtlqraamrZVtS2pakFbZ6NiqrIzup3d3dl3d3WEXd3mzc3Ny3
veifS6zPNu966uchxjrqCEuFaGLh6nZpps2bWtzLba2sza22W0mJMCVUP1Pd
i517w4qq6kQA0Fi5Ltel2tNNWza1tbbWm1ulqbGziuKuFcTTa2atNmrZta0G
MGhg2kMExJok267Ymw1KxajZ0dzVbWrZq2ta1s1tbaWyTQmk7l7lOCCCyyyy
zK9nEzMjh1W0bEwsjMrIq4u6uhQogGlaNS4Wi5Jpps2bWtrba02ttlqbG1bz
XEU92Kns53sXd3Vx29WVZF3d04973l4ji5OZwuTqdzauzTZtbWrWtmra20tT
Y2q3ObmrlXE5q2tNWmmrZtbWrW1s2ttLU2NjjrtX0REknlYYk0tFqGDQxMGm
DTTFwcckcJcg5Lw5giIiAIheDJJmZJoCywkJQwGDS0OE0NDEwZa2trW1ulqa
Wzw89XPPl5cOFps2ejtabNW1q1rZu1tpamg0hiFXrr3RE3HvZr6VRuVkhQsi
5PqI8vgBjJ6+sUN4oe2+0m0JWab6ozYttpVMplTLOGovuT/Y94Rxv7wjtNVT
4TeL2rER/L8ir7fl+10S+Wfl+hCPvNY1Pe9/T78PRTraRGoahrjKVNl+X4dt
qtY9X/flVZY+yTcqqsYOuBS1y+u+3vwmJ8+iI516Qj9GX63BVTo4+f8vur9n
0vR1EENvfNEhfOEesI1wLzTKqxGQEOiqSCAKr9qKCKNJYNlN/OiOqqRnuxym
7723CfqJGh6+Y2CtlyTQkgzefkIEEwj6DyEcc6H0IfjRAhAezsXXEA2MMxqy
egxHHsfuJJjEKms1NpZWVNZSs2WzS2bLZstmlpZUpqUqaWZqU2lmpSyazaVZ
rNrYrJMWUJ3RRxFiNZeXptVXZrbel5Ejx9gR0RRvcfj6emO3FXsudPz8vGM+
ffhVVXlhI6fLZPJ678Skv8/2v8c4xj0+SI/ieRI2hHX+NEY+ODn8xKVNRfsr
349IR/nwU+m/mqi/1MRi53pWNvHh928fHrqfryXTfS0iPxrkIbq7Am/Jfg/Y
9F1Hb/5nyYaHREb0+Vxe4UFVKbbkUJqbnchxflOCjddazJqw0W9Nnnw3gGPw
wfAPF5cuQw5MmHBly5ctwxMGW4YmHDcsHJkMuXLgy5cOTDhyYcOHDkwYMGc5
zgwYMGcYxnBgwYZly1M4MGDBjbGEwmUyluRqNBwtmFqOVwMgYDDn4QhHiKSg
Pmr7Fa+yzBCu7WHycrplIXkgTzqPEezwha96vWI+k77LD5E4Vhcg52SnWeDC
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
c8TX5k1NT931n3ZkmZ+/6+6ndvvGxrqSaI7vMiJn3vG3d113fOvew6qr3vbc
PvZtzd9svad3N3VZr6766pt1W1VVdVERGx6JPe07SINcy5mn3RtVLj1zW09q
+nZtxHdd3u9uvpn3d2vd7de7uZnbrqq7uzt3hm7u7tVnb6q3G+7u3I3d3Xe5
md+E+9CQILPxSvsj/ARfqfwCV+FL+sKv8Ptq/tEr837liMErMlgUrMgwxQn1
r+OgnmVTi/dF4uP+tXBEf/uCj1/LjUnlf6/IfCuGqfnlcpdMqnOGSwrFZVMq
Sri3G1t/Xey7gDW75rKgeDPtxk9wtqW0LaFtCWtBUIgCKtSzZTZpspsprDKU
nWSNwjKkbxtVkW8BVNlTdlS2i4qRlypYRlRQ+0uPoqxsbGx8ISSL/8iI1sNt
ITGMzMZlYyzicOakaSWKKtFikLofSdoLhRL0ngjlSF9kSubkpL1dir2QXzKR
M8QFU0n9Kb1I/8I4qhyrhNuyN73E+s+VS1AVT3TznwohfsOwq9lP1a+XSnvf
rfYUhdq+BTqA84SXTq0Kv6PJftSvk/H/KW9yF/OaoZiqqvEy+SKGbJjatG2A
ALYryrNrWvZtI+iey+EUN6JkUMKvg+WKYOJzv6xWoCqbPE0molTPmGYKLrBX
QVLbKl/4gKppVecXNplUPvrvGouws4vtTE+Mk9XiOWSTyQ4wBeLoSvRVOzn/
VH2+yKG0W93T1FW70L4ptSvhw9fSHnrVIeuVJGZUTSq2eTu0nuilzzXvEqey
2RQ5urxeV0SF2ZUVXhOiku/T6hK5dSwSvUUPKkLwRLteFewQ83w8qkXqhqey
whL1BHc9Mo9aSfjeKi8Nqd6hoSvPiynoBmSi7vhhSXKuVttc7bvVxa9y9ESS
SSYJeMqmoE6MULwVUbp1pKmotWqkfeVcVDTYp5JJZSfIu2/S8FX/kFOE9qh5
pj1vlV1LZPd8ILsj4ihz97OM6BHlQSRnOrE/CSEEQ0ZIbbbbOUSQMQ0o/M/Q
X7yB6sT9z7Pwfi/F9n4/s+z8e9gZqlP137iv1DrfBq/xr6FXa31kte8AAOKm
tsZUj87BNY/fUvrEqdU2TItqobhbSuyYFVvWyZJlGIyjKsDJMoxGExGUZRim
QwMJiMhlGBlWSyWUymJkZGJgZDJYWFksmTEMQyowTJGUWEyQ1FtcVI0tydsz
K72YiMGszJqqH4usqr8cQ6L7TKZWLLLTS2WazZWWVmprKazTaWFpZspqZZmz
LSzUzUpk202mrNZWzWVlu3PaoZ+/Ufm/GKHhMKvBY/YxmMkSRJEkCW1rXhtr
V2+Lz6jrUsEl50fyP6L/tF/XUNjaz+t/KQgMTKtP42AfwN/3V/o8UN5PXDgV
/cqRxtioaCNVKNnSdoRxvkwHIs1jMlyx0mJqj/RoqReVFY/6FKyQsIDK95e1
8V3r+RQcJ0gWSqXaVqS0Ot+hq1XpTZa3neqAH+dqtTSCyJXPVpHipTkKcF4l
9dfgR3iPQnK8WyKPB6dhR4abszJJJJJI+ooJF5T1VA4N9RwtBSrzaLgUPQq1
F516X/O2ryCOSkuAjOvgqj45FmJmMxDMUv9HrF1XoFL0iNB4kuq7zvhIzKqM
TyYMnVzFS5pDvpUXY61DrdtFT5b8FNkymXewPFEneJSXgeCK/FRJ7y2ubm9l
ZCVh4HSvxsqieF4oukeLYUPlKtHmf3Ij+GQjcRvSjzCMiLumVoRWV7vTxXqr
6HxTHMPA2ee+oR8duIcfWiO/w9zvJbhS7ffqrZS5ckj0ucUjIR9KNB4HMkeP
Ko9a+AZmDMijJixYUib2xUawyrFhtZqmU1mDIMjQmqE2KZSCdl625I/dAVTz
fCh3vsvCpLzCNQj0nnXBVTevSp53XmqdXvFI9YtABkWHbFSbBSxSV6vezvhI
myr/NF73bX8Nq1d9t6ar5u202/JvagAd9W9+L+H+58iqm9fpYiOSme52JJU0
VdahnuG1qq3+Ns+G9CP9+HmpGf/NfWiPpVPP7yR5nLu8SRP29D8m0tKRkI3h
S6GJH2974+p/x8X/byHX9dv6DKmMqs9WVNQ8LKMUZWZGSYoYBq0qRlwlzWRM
rIpXpi0raEanp+Oh8uaUeu0/OLJKWxmLMlllQZitFtigsFgsFjFBrIFf/n9I
fZQj6M3OKqeWKGn6vKH3zdVS5ZR50ZLyi084qnZD1lVWYlNbBS4D9hEe0r3q
+ikkLvs4vBC5+pyqV6Pr4voAbEicriozBYxK2VI5RG7erNypU1bfZ6UtrocR
R7Xz6d6XX2u/6vLWMzNIjeLrkAOv3HD47dRVEPrE8U9NP0fDff7UYTVsgSSM
ZIxkjGSMZIES0fMYsFVHcg53o2zyP/fiuaI104Yuikbng1qT6GRRupVtEYij
vTmtyVW9QwqeE8Wg8VctFI8+33ZU9Yf417Ekqed+Tiil/PIjr3e1f/zCj4hS
ylw89centN5w32toUtsGAAWuqra3NcdPjc6+xW29m2q9SqWqvnegpwL5s+wA
fCkSnkJzXl84clFpEV2TMjifZkTMUoafNS2pX4T/b8KIGqmUVLbIlGrB6/F9
tqUl5V/R7aqifD2pU9Xa81KdSksi9RKVPdNkxNzDn3ktGbGr+f74lKn6R7ze
47UBiwx92JWxX6fHy4xmb3tXpm4Sbebldkj9PtOtt1KvpGqFzdoiL4XpRA+Z
UqYNQjyWV1bQpbhvCMV/D1uf6q+l1db8Lo443dVIdoYqqMi0zE1RiYmdinZp
Ee6uEt8h5EkqZSjWUGZO2vbNjrJdPKqL79bDjeLtvRG3N6+D4zRw2MdbCqm0
Bb7b6bsq+P2a56ffRU9z6e5V/HKhtFdPga1tRExOJI+P6ZOaork4V3+JI0iP
l9jgI2qqq9r6/mqqfzdOlikOK+aInkPvi27+IvKPWz6a2bV/VkI994jXXu+u
eVCZQHlfwUjVUWnj8m1PXt54qiYiNjvW2plVrNvbbcXGAEmttbP+mJEZgUlp
MpKtYiV8IeGQLVSFwxCO1XMR6oHeiPlF9NlSPtazelD+ya+tfJPovgfohS+N
io0nxcvJEdabV0cbCjaqesSlTVT7foiMzLt+LUltCNhKVP0KDC+RUaWivCI2
S2rcpLXnBR2yKpfEmKMWBSnnbURtfht053cJgW01NaaVTZbTZVNlaU2pZrSy
2mmqWWylZS2ZtKalKppVNKxZWaqazbUtmtpZbTKmypZpZss0s0s02VNmzZZZ
ZZTTKUpMpps0pRNptNZrLZbLNSAAfbuPdvXr4Pcr3IUu9VydTEyKO6I8uSb4
JDwkVa+3lj3zqh7320qXl2em/Z2quLThbVrja5rcpwkRERGEjyvHQOrT2jt6
vSXfDoDCr6UdAjxW3loyytqI4o66jaoddUKXHE5tPCI+tKHWjY6nWVL4pFXb
fsSPr0b8hFaNbVM13No6kyNtrRERBtW23NxpGqhMskvWkNURvG7ZUj7OF+FU
6pRvTIRtHGFmSRkGQZBkWRCqFUBQokaAViLtigbbPLs3H2Klx3iUqYpY6OWU
RzDkSOhmMEn+6psqW4fWOVaoj9dTtStgpeUdNFXY6ztQHVsrMoGoo6T/DKQJ
1KsjaEsZfZxoui4vWiPrfansmURjUtGLCRl9SpU83y3fUfucel+BTmvvX3lU
PR9f0b0fB82WJmZBV+CwlPPmwNobVI8Oan/LKsYExh3mL1dV7F3+hjaye7T8
NdX/v4Ie3wfMw9yRqp2cXr2L56Hf0ok67Sc1VY7KV8tIWcba9u+f8uvk5z7/
G4Uo2KKijYo2KNiSj3qtqmtc81vkV1StPciDFPQtItotEUKqoQGgFS4cWlS0
tVq0tbaa1TKKNCjJqzCwUZTFYmmRc1g2sjG0VLVItWFMphSWQpkhmUTFGVIa
VajSlL7eKHz6I1foH6Qpd4fMt651lFTcMUp798XW5KodJxtU73jZTOW/IRvc
Ej7u5zjdOGwSago0qpesNqyzEyszCspJsijZpvcwFUya+KkZmmNeooxCjMQK
pu3+4z3i/CnEHcKWTorJLoD60ZbSR91U8ReIvreXN4Uqffh9nK6Q+DPBA+Lz
LYSvilzfNmTFZZZ1+EI2ktGEkzJ7O2yq7Pc7xWpuEZnFtRSXGVJQ6lXpzel8
Y1EpU4ePO6v12fKeGusI6w9HaBeTaIPKUltUhZvFS2MpDGzKfEqxNwjFGsK+
bU2hG8Iyb6hGdiR31n272zbNVmBtzz6HI8xuXSZyCQ0lGFhHAkmbIEHHudBz
2jrksymMqqZizBJsRD7YeogB+Z7HuxhOtLaW0tpbSRAzjXVwJsqpYom4lKnF
AaVG1ZKn5ccN/IqptNNov1PfdEdHNc2imdWakxWkRtU4bfZjMuLMse1cWeM2
WkRtzK3ZZZjGURgmYpWEp36xR0KpdHsxVVWkSswkuHWLZEZzCPPYeW1A71Tl
2XO2u+SdYrriDMpF4gDj5LpmfP3vHP7apXp6nHutsuJI91sRyUqUYACRpRLS
lYwpSsYUpWMKUrGFKVjEpUkXFWszNmyyzTTZssss2bNmzZsqWWUpSmmmZmWW
aaUpJtNprNZbLYZgyiMzFkg75Jb1tGiqq0NWVq0OlmcvL5Grl3qQ96I6ymkq
7YV6ojapwej0miPOLMJmVMyTMUzFMwTwKtqKtFJee5N7wKRsCq74qhNuTvxS
quMVQef377JbURkEXMwUPLr32enlIVpxVFwljx5Ot5SvLPu1N8fCr0dXpU7o
jnilGSksUpe0beNLUIzXoz0sJExHXz6yUdnh1qQvnFHurwcwjoVZ06sedefJ
jiiOQ+AoWFTePNVq3bSUchod7arOEXEFHwWKqWVgkMv06ZFFX3EkqdPLx0vK
Kl+e6eUYVZev3MA6YV6sj3hGKtqd4lKnoyL+CI86B3VJfqzn0n9z4Xk2oj0k
o9j4fZtPpsZhMyqxUTsQKxaOO60Va9ziEbXBJhI0ylSx+FxCPgZuLXS7lOXd
/klLVeJsqR5Uhq1WV9icV3Kcukmf56pQ1VSPk+zsnf5Z5lWms4ZmZmZmNZWb
m9Qx+Ctk4wqxgFxZxVOBtVfB//i7kinChIQkDauQ

--497817361-118116108-1174478519=:534--
