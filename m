From: Peter Chubb <peter@chubb.wattle.id.au>
Subject: Re: Making the NS83820 usable on IA64
Date: Wed, 17 Mar 2004 19:54:28 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16472.4676.684522.635248@wombat.chubb.wattle.id.au>
References: <16471.52400.222262.824746@wombat.disy.cse.unsw.edu.au>
	<20040316214912.32b4c530.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040316214912.32b4c530.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "David" == David S Miller <davem@redhat.com> writes:

David> On Wed, 17 Mar 2004 14:57:36 +1100 Peter Chubb
David> <peterc@gelato.unsw.edu.au> wrote:

>> The idea is to tell gcc that the IP header is 2-byte aligned, so it
>> can generate the right code to access it.  Otherwise, it tries to
>> do a 4-byte load when trying to extract the header length bitfield,
>> which traps.  As far as I read the C standard, gcc can do almost
>> whatever it wants as regarding the alignment and underlying storage
>> size of a bitfield, so it's free to assume 32-bit alignment if it
>> wants.

David> This makes every piece of code only able to assume 2-byte
David> alignment.  I don't think this will get accepted :)

Well, there are at least two other alternatives.

One is to copy the buffer to force iphdr to be
4-byte aligned.  If you want to access a bitfield, it should be
aligned at whatever the compiler expects bitfields to be aligned at --
in this case, 4-bytes.  Last time I brought up this solution it was
shouted down.

The other is to get rid of the bitfields and to do explicit masking
and shifting, every time ihl and version are accessed.  

And something may have to be done if we ever port to a big-endian
machine with struct alignment constraints.  We're saved at present by
ntohl and friends on the non-aligned saddr and daddr etc.


Something has to be done, however.  The standard driver plus stack
won't even do 100Mb/s; with any kind of network load the whole machine
becomes unusable.  with the patch I sent before, it gets to
315Mb/s (UDP echo server, 1024 byte packets).  If I enable interrupt
holdoff code (currently disabled) I can push it to 340Mb/s (and it's
spending most of its time in rx_interrupt() -- system time close to
99%).  Even this is pretty appalling.  (Numbers derived using ipbench.sf.net)
