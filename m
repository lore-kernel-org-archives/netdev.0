From: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 11:07:48 -0500
Message-ID: <4DF24154.3060505@uth.tmc.edu>
References: <4DF0E638.2010506@uth.tmc.edu> <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.uth.tmc.edu ([129.106.148.58]:6823 "EHLO mta3.uth.tmc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab1FJQHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 12:07:53 -0400
In-Reply-To: <4DF233CE.5020000@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2011 10:10 AM, Charles Bearden wrote:
> On 06/10/2011 08:56 AM, Eric Dumazet wrote:
>> Le jeudi 09 juin 2011 =C3=A0 10:26 -0500, Charles Bearden a =C3=A9cr=
it :
>>> I have come across a case that looks like it might be a kernel bug.=
 It appears
>>> that tcp keepalives sent by a remote system are ignored when they c=
ontain tcp
>>> timestamps, but are ACKed when they don't. When they are ignored, t=
he remote
>>> system resets the connection after a number of retries.
>>>
>>> I have replicated this problem on both Ubuntu 10.04 with a 2.6.32-3=
2-server
>>> kernel (x86_64) and CentOS 5.6 with a 2.6.18-238.12.1.el5 kernel. I=
'm sorry that
>>> I haven't had a chance to try to replicate the bug with a newer ker=
nel, though a
>>> co-worker has looked through changelogs for more recent kernels and=
 didn't find
>>> anything that looked relevant.
>>>
>>> From either of these hosts I run an application that connects to a =
remote host
>>> for 2-3 minutes, and that for most of that time sends no applicatio=
n data back
>>> and forth. After 30 seconds of no data from the Linux host, the rem=
ote host
>>> sends a garden variety keepalive. When the remote host includes tcp=
 timestamps
>>> in the keepalives, they are ignored by the Linux host, and the remo=
te host
>>> resets the connection after 10 unACKed keepalives. When timestamps =
are absent
>>> from the keepalives, the Linux host ACKs each one, and all is copac=
etic.
>>>
>>> Text output of a tcpdump trace of a connection that fails:
>>> http://pastebin.com/v6CpteJ9
>>>
>>> Text output of a tcpdump trace of a connection that succeeds:
>>> http://pastebin.com/KVLb3Mzh
>>>
>>> More details, in case you think they are relevant:
>>>
>>> My application creates a JDBC connection to a remote MS SQL Server =
and
>>> executes a statement that does not return a result set, and so it d=
oesn't
>>> need to pass application data back and forth while it executes. The
>>> statement takes 2 or 3 minutes to complete. I connect to two differ=
ent
>>> remote hosts: a Win2003 machine, and a Win2008R2 machine. The Win20=
03
>>> machine doesn't put timestamps in its keep-alives, so the applicati=
on
>>> completes successfully when connecting to that host. If tcp timesta=
mps
>>> are enabled on the Linux host, the Win2008 host includes them in it=
s
>>> keepalives, and they are unACKed, so the connection is reset; if th=
ey
>>> are disabled on the Linux host, the Win2008 host doesn't include th=
em in
>>> the keepalives, and the application completes successfully. I use (=
as
>>> you might expect) sysctl to disable tcp timestamps on the Linux hos=
ts.
>>>
>>> I have dumps for all permutations of CentOS/Ubuntu, Win200[38], and=
 +/-
>>> timestamps on the Linux side, and I will post them if the developer=
s think that
>>> they would be useful.
>>
>> Hi Charles
>>
>> I could not reproduce the problem here, even using a quite old kerne=
l as
>> receiver (2.6.9)
>>
>> 15:54:33.566192 IP 192.168.20.108.55926> 192.168.20.124.777: SWE
>> 479814493:479814493(0) win 14600<mss 1460,sackOK,timestamp 151666
>> 0,nop,wscale 7>
>> 15:54:33.566265 IP 192.168.20.124.777> 192.168.20.108.55926: S
>> 3714869381:3714869381(0) ack 479814494 win 5792<mss
>> 1460,sackOK,timestamp 54553041 151666,nop,wscale 2>
>> 15:54:33.566274 IP 192.168.20.108.55926> 192.168.20.124.777: . ack 1
>> win 115<nop,nop,timestamp 151666 54553041>
>> 15:54:33.566281 IP 192.168.20.108.55926> 192.168.20.124.777: P 1:5(4=
)
>> ack 1 win 115<nop,nop,timestamp 151666 54553041>
>> 15:54:33.566351 IP 192.168.20.124.777> 192.168.20.108.55926: . ack 5
>> win 1448<nop,nop,timestamp 54553041 151666>
>> 15:54:33.566375 IP 192.168.20.124.777> 192.168.20.108.55926: P 1:5(4=
)
>> ack 5 win 1448<nop,nop,timestamp 54553041 151666>
>> 15:54:33.566380 IP 192.168.20.108.55926> 192.168.20.124.777: . ack 5
>> win 115<nop,nop,timestamp 151666 54553041>
>> 15:54:43.577945 IP 192.168.20.108.55926> 192.168.20.124.777: . 4:5(1=
)
>> ack 5 win 115<nop,nop,timestamp 152668 54553041>
>> 15:54:43.578012 IP 192.168.20.124.777> 192.168.20.108.55926: . ack 5
>> win 1448<nop,nop,timestamp 54563053 152668,nop,nop,sack sack 1 {4:5}=
>
>> 15:54:53.597946 IP 192.168.20.108.55926> 192.168.20.124.777: . 4:5(1=
)
>> ack 5 win 115<nop,nop,timestamp 153670 54563053>
>> 15:54:53.598012 IP 192.168.20.124.777> 192.168.20.108.55926: . ack 5
>> win 1448<nop,nop,timestamp 54573073 153670,nop,nop,sack sack 1 {4:5}=
>
>>
>>
>> Are you sure frame tcp checksums are OK when the 'faulty' linux rece=
ive
>> them ? (tcpdump -v)
>
> I will check when I get into the office and let you know.

You are correct: the checksums in the keepalives are broken, though the=
y are=20
correct in the other segments from the Win2008 server. I have updated t=
he pastes=20
linked to above with 'tcpdump -v' output. I apologize for missing that =
problem=20
the first time around.
Chuck
