From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Wed, 6 Apr 2005 14:30:36 +0200
Message-ID: <20050406123036.GO26731@postel.suug.ch>
References: <20050405213023.0256.LARK@linux.net.cn> <1112717495.1076.22.camel@jzny.localdomain> <20050406143842.026B.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050406143842.026B.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050406143842.026B.LARK@linux.net.cn> 2005-04-06 14:45
> On 05 Apr 2005 12:11:35 -0400, jamal <hadi@cyberus.ca> wrote:
> > i.e if you fed the jenkins hash with 256 buckets - lets pick the number 1024 
> > samples of the data you showed earlier for how fwmark looks like,
> > how well would the result look like. 
> > And what if you fed it with something like 1024 incremental fwmark from 
> > say 1..1024?
> > 
> 
> The test result looks not good. See attached file.
> 
> So let's find a better way.

We need to provide some kind of option to the user so he can specify
the needs.  The & 0xFF will suit most just fine but has one essential
drawback which is that no distribution is done at all if the lower 8
bits are set to 0. For static marks this is no issue at all and even
for enumerated marks growing it takes quite some time to grow into
an area where it starts hurting. The problem obviously is if someone
splits the mark field into 2 parts and uses the upper 16 bits for
some special purpose just like you did. In such as case it would make
sense to either take all bits into account or let the user specify
a bitmask + shift.

So here is the same idea I posted before but revised:

Let the user specify one of the hash tables via a new TLV:
 - default: & 0xFF
 - ((mark & mask) >> shift) & 0xFF
 - jenkins for 16, 32, and 64 bits
 - FNV for 16, 32, and 64 bits

Why variations for type sizes? The chance of collisions reduces
a lot if the user exactly knows he'll never use more than 16bits
but 255 marks are not enough.

I'm cooking up a patch for this today together with a fix to
allow 64bit values for the mark.
