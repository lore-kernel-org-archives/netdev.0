From: Eric Paris <eparis@redhat.com>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Fri, 07 Mar 2014 22:56:52 -0500
Message-ID: <1394251012.17193.9.camel@localhost>
References: <7457128.6VP2v68V93@x2> <87wqg8zfj4.fsf@xmission.com>
	 <1394232722.17779.57.camel@flatline.rdu.redhat.com>
	 <20140307.194801.1893514114998807038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, sgrubb@redhat.com, rgb@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-audit@redhat.com, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307.194801.1893514114998807038.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 19:48 -0500, David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Fri, 07 Mar 2014 17:52:02 -0500
> 
> > Audit is non-tolerant to failure and loss.
> 
> Netlink is not a loss-less transport.
I'm happy to accept that (and know it to be true).  How can I better
architect things?  It seems Eric is complaining that when we get a
request for info, we queue that info up, and then use a kthread to make
it available when the task next calls recv.  By using blocking sockets
in the kthread we have no problem with the size of the socket read buf.
If we switch to non-blocking sockets how can we possibly queue up more
than rmem size of data?  (honestly, if userspace used INT_MAX it is
almost certainly overkill for even the largest rulesets, but
theoretically, it's not...)

Is our design somehow wrong?  Flawed?  Mind you it's pretty dumb that we
do basically the same thing in 3 different audit code path, but the
architecture doesn't seem crazy to me.  Then again, I'm not brilliant by
any stretch!

   +------------------------------------------------------------------+
   |                                                                  |
   |               auditctl (audit tool run by root)                  |
   |         netlink send                         netlink receive     |
   +------------------------------------------------------------------+
                  +                                        ^
                  |                                        |
                  v                                        +
      +----------------------------+        +------------------------+
      | kernel audit generate skbs |        | send skbs to userspace |
      +----------------------------+        +------------------------+
                  +                                        ^
                  |        +------------------------+      |
                  +------->| send skbs to a kthread |+-----+
                           +------------------------+
