From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 22:36:29 +0100
Message-ID: <564CEF5D.3080005@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:17416 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756913AbbKRVg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 16:36:28 -0500
In-Reply-To: <564CEB0C.40006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.11.2015 um 22:18 schrieb Florian Weimer:
> On 11/18/2015 09:23 PM, Stefan Priebe wrote:
>>
>> Am 17.11.2015 um 20:43 schrieb Thomas Gleixner:
>>> On Tue, 17 Nov 2015, Stefan Priebe wrote:
>>>> I've now also two gdb backtraces from two crashes:
>>>> http://pastebin.com/raw.php?i=yih5jNt8
>>>>
>>>> http://pastebin.com/raw.php?i=kGEcvH4T
>>>
>>> They don't tell me anything as I have no idea of the inner workings of
>>> asterisk. You might be better of to talk to the asterisk folks to help
>>> you track down what that thing is waiting for, so we can actually look
>>> at a well defined area.
>>
>> The asterisk guys told me it's a livelock asterisk is waiting for
>> getaddrinfo / recvmsg.
>>
>> Thread 2 (Thread 0x7fbe989c6700 (LWP 12890)):
>> #0  0x00007fbeb9eb487d in recvmsg () from /lib/x86_64-linux-gnu/libc.so.6
>> #1  0x00007fbeb9ed4fcc in ?? () from /lib/x86_64-linux-gnu/libc.so.6
>> #2  0x00007fbeb9ed544a in ?? () from /lib/x86_64-linux-gnu/libc.so.6
>> #3  0x00007fbeb9e92007 in getaddrinfo () from
>> /lib/x86_64-linux-gnu/libc.so.6
>
> Stefan,
>
> please try to get a backtrace with debugging information.  It is likely
> that this is the make_request/__check_pf functionality in glibc, but it
> would be nice to get some certainty.

sorry here it is. What I'm wondering is why is there ipv6 stuff? I don't 
have ipv6 except for link local. Could it be this one?

https://bugzilla.redhat.com/show_bug.cgi?id=505105#c79

Thread 31 (Thread 0x7f295c011700 (LWP 26654)):
#0  0x00007f295de3287d in recvmsg () at 
../sysdeps/unix/syscall-template.S:82
#1  0x00007f295de52fcc in make_request (fd=35, pid=26631, 
seen_ipv4=<optimized out>, seen_ipv6=<optimized out>,
     in6ai=<optimized out>, in6ailen=<optimized out>) at 
../sysdeps/unix/sysv/linux/check_pf.c:119
#2  0x00007f295de5344a in __check_pf (seen_ipv4=0x7f295c00e85f, 
seen_ipv6=0x7f295c00e85e, in6ai=0x7f295c00e840,
     in6ailen=0x7f295c00e838) at ../sysdeps/unix/sysv/linux/check_pf.c:271
#3  0x00007f295de10007 in *__GI_getaddrinfo (name=0x7f295c00e8b0 
"10.12.12.55", service=0x7f295c00e8bc "2135",
     hints=0x7f295c00e910, pai=0x7f295c00e908) at 
../sysdeps/posix/getaddrinfo.c:2389
#4  0x000000000050287e in ast_sockaddr_resolve (addrs=0x7f295c00e9d0, 
str=0x7f295c00ea30 "10.12.12.55:2135", flags=0, family=2)
     at netsock2.c:268
#5  0x00007f2958963ba2 in ast_sockaddr_resolve_first_af 
(addr=0x7f29300591d8, name=0x7f295c00ea30 "10.12.12.55:2135", flag=0,
     family=2) at chan_sip.c:30689
#6  0x00007f2958963cb5 in ast_sockaddr_resolve_first_transport 
(addr=0x7f29300591d8, name=0x7f295c00ea30 "10.12.12.55:2135",
     flag=0, transport=1) at chan_sip.c:30720
#7  0x00007f29588fd3cc in set_destination (p=0x7f2930058cc8, 
uri=0x7f29300576e8 "sip:9052@10.12.12.55:2135;line=to7a729l")
     at chan_sip.c:10455
#8  0x00007f29588fe6e0 in reqprep (req=0x7f295c00fee0, p=0x7f2930058cc8, 
sipmethod=4, seqno=287, newbranch=1) at chan_sip.c:10778
#9  0x00007f295890a201 in transmit_state_notify (p=0x7f2930058cc8, 
state=1, full=1, timeout=0) at chan_sip.c:13259
#10 0x00007f29589141bb in cb_extensionstate (context=0x7f295c010cd0 
"hints", exten=0x7f295c010c80 "9052QS", state=1,
     data=0x7f2930058cc8) at chan_sip.c:15117
#11 0x000000000050ebf6 in handle_statechange (datap=0x7f293acef830) at 
pbx.c:4972
#12 0x0000000000555f8e in tps_processing_function (data=0x1f24f28) at 
taskprocessor.c:327
#13 0x0000000000569280 in dummy_start (data=0x1ed76f0) at utils.c:1173
#14 0x00007f295d5dcb50 in start_thread (arg=<optimized out>) at 
pthread_create.c:304
#15 0x00007f295de3195d in clone () at 
../sysdeps/unix/sysv/linux/x86_64/clone.S:112
#16 0x0000000000000000 in ?? ()

>
> Which glibc version do you use?  Has it got a fix for CVE-2013-7423?
>
> So far, the only known cause for a hang in this place (that is, lack of
> return from recvmsg) is incorrect file descriptor use.  (CVE-2013-7423
> is such an issue in glibc itself.)  The kernel upgrade could change
> scheduling behavior, and the actual bug might have been latent before.
>
> Theoretically, recvmsg could also hang if the Netlink query was dropped
> by the kernel, or the final packet in the response was dropped.  We
> never saw that happen, even under extreme load, but I didn't test with
> recent kernels.
>
> The glibc change Hannes mentioned won't detect the hang, but if there is
> incorrect file descriptor reuse going on, it is possible that the new
> assert catches it.
>
> Florian
>
