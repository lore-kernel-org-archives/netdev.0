From: Alex Bligh <alex@alex.org.uk>
Subject: Re: kernel panic in skb_copy_bits
Date: Sun, 30 Jun 2013 10:13:35 +0100
Message-ID: <6BFD5AF235F72F13CE646A0D@nimrod.local>
References: <51CBAA48.3080802@oracle.com>
	<1372311118.3301.214.camel@edumazet-glaptop>
	<51CD0E67.4000008@oracle.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>, zheng.x.li@oracle.com,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xen Devel <xen-devel@lists.xen.org>,
	Jan Beulich <JBeulich@suse.com>, "David S. Miller" <davem@davemloft.net>
To: Joe Jin <joe.jin@oracle.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <51CD0E67.4000008@oracle.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org



--On 28 June 2013 12:17:43 +0800 Joe Jin <joe.jin@oracle.com> wrote:

> Find a similar issue
> http://www.gossamer-threads.com/lists/xen/devel/265611 So copied to Xen
> developer as well.

I thought this sounded familiar. I haven't got the start of this
thread, but what version of Xen are you running and what device
model? If before 4.3, there is a page lifetime bug in the kernel
(not the xen code) which can affect anything where the guest accesses
the host's block stack and that in turn accesses the networking
stack (it may in fact be wider than that). So, e.g. domU on
iCSSI will do it. It tends to get triggered by a TCP retransmit
or (on NFS) the RPC equivalent. Essentially block operation
is considered complete, returning through xen and freeing the
grant table entry, and yet something in the kernel (e.g. tcp
retransmit) can still access the data. The nature of the bug
is extensively discussed in that thread - you'll also find
a reference to a thread on linux-nfs which concludes it
isn't an nfs problem, and even some patches to fix it in the
kernel adding reference counting.

A workaround is to turn off O_DIRECT use by Xen as that ensures
the pages are copied. Xen 4.3 does this by default.

I believe fixes for this are in 4.3 and 4.2.2 if using the
qemu upstream DM. Note these aren't real fixes, just a workaround
of a kernel bug.

To fix on a local build of xen you will need something like this:
https://github.com/abligh/qemu-upstream-4.2-testing/commit/9a97c011e1a682eed9bc7195a25349eaf23ff3f9
and something like this (NB: obviously insert your own git
repo and commit numbers)
https://github.com/abligh/xen/commit/f5c344afac96ced8b980b9659fb3e81c4a0db5ca

Also note those fixes are (technically) unsafe for live migration
unless there is an ordering change made in qemu's block open
call.

Of course this might be something completely different.

-- 
Alex Bligh
