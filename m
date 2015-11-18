From: Florian Weimer <fweimer@redhat.com>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 22:18:04 +0100
Message-ID: <564CEB0C.40006@redhat.com>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CDE2F.8000201@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/18/2015 09:23 PM, Stefan Priebe wrote:
> 
> Am 17.11.2015 um 20:43 schrieb Thomas Gleixner:
>> On Tue, 17 Nov 2015, Stefan Priebe wrote:
>>> I've now also two gdb backtraces from two crashes:
>>> http://pastebin.com/raw.php?i=yih5jNt8
>>>
>>> http://pastebin.com/raw.php?i=kGEcvH4T
>>
>> They don't tell me anything as I have no idea of the inner workings of
>> asterisk. You might be better of to talk to the asterisk folks to help
>> you track down what that thing is waiting for, so we can actually look
>> at a well defined area.
> 
> The asterisk guys told me it's a livelock asterisk is waiting for
> getaddrinfo / recvmsg.
> 
> Thread 2 (Thread 0x7fbe989c6700 (LWP 12890)):
> #0  0x00007fbeb9eb487d in recvmsg () from /lib/x86_64-linux-gnu/libc.so.6
> #1  0x00007fbeb9ed4fcc in ?? () from /lib/x86_64-linux-gnu/libc.so.6
> #2  0x00007fbeb9ed544a in ?? () from /lib/x86_64-linux-gnu/libc.so.6
> #3  0x00007fbeb9e92007 in getaddrinfo () from
> /lib/x86_64-linux-gnu/libc.so.6

Stefan,

please try to get a backtrace with debugging information.  It is likely
that this is the make_request/__check_pf functionality in glibc, but it
would be nice to get some certainty.

Which glibc version do you use?  Has it got a fix for CVE-2013-7423?

So far, the only known cause for a hang in this place (that is, lack of
return from recvmsg) is incorrect file descriptor use.  (CVE-2013-7423
is such an issue in glibc itself.)  The kernel upgrade could change
scheduling behavior, and the actual bug might have been latent before.

Theoretically, recvmsg could also hang if the Netlink query was dropped
by the kernel, or the final packet in the response was dropped.  We
never saw that happen, even under extreme load, but I didn't test with
recent kernels.

The glibc change Hannes mentioned won't detect the hang, but if there is
incorrect file descriptor reuse going on, it is possible that the new
assert catches it.

Florian
