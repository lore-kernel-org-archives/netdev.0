From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 10:41:18 -0800
Message-ID: <4F05EECE.1000708@hp.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com> <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com> <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com> <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F0382BB.5060601@hp.com> <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com> <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com> <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com> <1325757891.2415.7.camel@edumazet-HP-Co
 mpaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Michel Hautbois <jhautbois@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:31939 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab2AESvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:51:42 -0500
In-Reply-To: <1325757891.2415.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2012 02:04 AM, Eric Dumazet wrote:
> Le jeudi 05 janvier 2012 =C3=A0 10:57 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>>   # netperf -H 192.168.0.1 -c -l 10 -t UDP_STREAM -- -m 1500
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.1 (192.168.0.1) port 0 AF_INET
>> Socket  Message  Elapsed      Messages                   CPU      Se=
rvice
>> Size    Size     Time         Okay Errors   Throughput   Util     De=
mand
>> bytes   bytes    secs            #      #   10^6bits/sec % SU     us=
/KB
>>
>> 106496    1500   10.00       54477      0        0.0     65.34    10=
0.000
>> 1073741824           2.25            0               0.0     65.34  =
  -1.000
>>
>
> Hmm... this sounds you have half duplex somewhere ?

Why?  A netperf UDP_STREAM test is "purely" unidirectional (*).  I=20
suspect the numbers look funny thanks to the 32-bit compilation bugs=20
(format statement issues).

Apart from updating to the top of trunk bits from=20
http://www.netperf.org/svn/netperf2/trunk , another way to run the test=
=20
with the existing bits would be to get the explicit "omni" output going=
=20
with something akin to:

netperf -H 192.168.0.1 -t omni -c -l 10 -- -T UDP -m 1500

raj@tardy:~/netperf2_trunk$ src/netperf -t omni -H localhost -c -l 10 -=
-=20
-T udp -m 1500
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to=20
localhost.localdomain () port 0 AF_INET
Local       Local       Local Elapsed Throughput Throughput  Local=20
Local  Remote Remote Local   Remote  Service
Send Socket Send Socket Send  Time               Units       CPU    CPU=
=20
    CPU    CPU    Service Service Demand
Size        Size        Size  (sec)                          Util   Uti=
l=20
   Util   Util   Demand  Demand  Units
=46inal       Final                                            %=20
Method %      Method
1254744     1254744     1500  10.00   12869.82   10^6bits/s  42.05  S=20
    -1.00  U      1.071   -1.000  usec/KB

Or to avoid the wraps, use the keyval output format:

raj@tardy:~/netperf2_trunk$ src/netperf -t omni -H localhost -c -l 10 -=
-=20
-T udp -m 1500 -k
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to=20
localhost.localdomain () port 0 AF_INET
LSS_SIZE_END=3D1390392
LSS_SIZE_END=3D1390392
LOCAL_SEND_SIZE=3D1500
ELAPSED_TIME=3D10.00
THROUGHPUT=3D12640.22
THROUGHPUT_UNITS=3D10^6bits/s
LOCAL_CPU_UTIL=3D41.19
LOCAL_CPU_METHOD=3DS
REMOTE_CPU_UTIL=3D-1.00
REMOTE_CPU_METHOD=3DU
LOCAL_SD=3D1.068
REMOTE_SD=3D-1.000
SD_UNITS=3Dusec/KB

One could also whittle the output down by using the omni output=20
selectors -=20
http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Omni-Output-=
Selection

rick jones

* well, there may be a stray, delayed TCP ACKnowledgement on the contro=
l=20
connection while the UDP traffic is flowing, but even that I believe=20
will be from netperf to netserver - ie in the direction the UDP_STREAM=20
traffic is going
