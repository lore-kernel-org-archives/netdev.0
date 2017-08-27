From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Sun, 27 Aug 2017 20:47:25 +0000
Message-ID: <20170827204725.GA8625@amazon.com>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
 <20170822.213030.1848111782253505433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <shuah@kernel.org>, <richardcochran@gmail.com>,
        <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <eduval@amazon.com>,
        <anchalag@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170822.213030.1848111782253505433.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 09:30:30PM -0700, David Miller wrote:
> From: Vallish Vaidyeshwara <vallish@amazon.com>
> Date: Wed, 23 Aug 2017 00:10:25 +0000
> 
> > I am submitting 2 patch series to enable hires timer to timeout
> > datagram sockets (AF_UNIX & AF_INET domain) and test code to test
> > timeout accuracy on these sockets.
> 
> This is not reasonable.
> 
> If you want high resolution events with real guarantees, please use
> the kernel interfaces which provide this as explained to you as
> feedback by other reviewers.
> 
> I'm not applying this, sorry.

Hello David,

I respect the decision not to upstream this patch series, however I
wanted to provide additional details. Application wanting high
resolution events with real guarantees is not the case, but the case
here is regression in system call behavior:

1) Change in system call behavior:
strace from 4.4 test run of waiting for 180 seconds on datagram socket:
10:25:48.239685 setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\264\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
10:25:48.239755 recvmsg(3, 0x7ffd0a3beec0, 0) = -1 EAGAIN (Resource temporarily unavailable)
10:28:48.236989 fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0

strace from 4.9 test run of waiting for 180 seconds on datagram socket times out close to 195 seconds:
setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\264\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0 <0.000028>
recvmsg(3, 0x7ffd6a2c4380, 0)           = -1 EAGAIN (Resource temporarily unavailable) <194.852000>
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0 <0.000018>

This is the change in behavior of system call that is causing our application
to regress on 4.9 kernel. There are events which need to be run on timeouts
and now response time for such timeouts on 4.9 kernel are being triggered
with extended delay of close to 195 seconds as in one of the test runs
shown above.

2) Comparison with MacOS:
I ran the same test on OS X El Capitan version 10.11.6 and the behavior is
consistent with Linux 4.4 Kernel behavior. I have not tested the program on
other flavors of OS like HPUX or AIX or Solaris, but I guess if these OS
implement SO_RCVTIMEO and tested, this behavior will not be different than
Linux 4.4 kernel.
  
3) Standards Specification:
Opengroups standard does not talk about how quick SO_RCVTIMEO need to respond
for timeouts. However, the standards for select system call do mention that
timeout need to respond quickly. It would be good to restore SO_RCVTIMEO
behavior to 4.4 kernel and have SO_RCVTIMEO be consistent with select timeout.

4) Changing application code:
Any change to application code to accommodate this change of behavior in system
call breaks application migration between 4.4 kernel and 4.9 kernel.
Moreover, making application code change is not feasible in all cases as in
the case where the source code is not available (third party vendor).

Thanks.
-Vallish
