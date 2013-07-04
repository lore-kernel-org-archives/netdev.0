From: Alex Bligh <alex@alex.org.uk>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 04 Jul 2013 13:57:16 +0100
Message-ID: <06F8DA5DD1D9E277F2AF6F1E@Ximines.local>
References: <51CBAA48.3080802@oracle.com>	
 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>	
 <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com>	
 <1372666283.14691.8.camel@zakaz.uk.xensource.com>	
 <51D53896.1060405@oracle.com>	
 <1372928382.7184.16.camel@kazak.uk.xensource.com>	
 <1372930465.4979.82.camel@edumazet-glaptop>	
 <1372931565.7184.32.camel@kazak.uk.xensource.com>
 <1372932730.4979.96.camel@edumazet-glaptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Jin <joe.jin@oracle.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372932730.4979.96.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--On 4 July 2013 03:12:10 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> It looks like a typical COW issue to me.
>
> If the page content is written while there is still a reference on this
> page, we should allocate a new page and copy the previous content.
>
> And this has little to do with networking.

I suspect this would get more attention if we could make Ian's case
below trigger (a) outside Xen, (b) outside networking.

> 	memset(buf, 0xaa, 4096);
> 	write(fd, buf, 4096)
> 	memset(buf, 0x55, 4096);
> (where fd is O_DIRECT on NFS) Can result in 0x55 being seen on the wire
> in the TCP retransmit.

We know this should fail using O_DIRECT+NFS. We've had reports suggesting
it fails in O_DIRECT+iSCSI. However, that's been with a kernel panic
(under Xen) rather than data corruption as per the above.

Historical trawling suggests this is an issue with DRDB (see Ian's
original thread from the mists of time).

I don't quite understand why we aren't seeing corruption with standard
ATA devices + O_DIRECT and no Xen involved at all.

My memory is a bit misty on this but I had thought the reason why
this would NOT be solved simply by O_DIRECT taking a reference to
the page was that the O_DIRECT I/O completed (and thus the reference
would be freed up) before the networking stack had actually finished
with the page. If the O_DIRECT I/O did not complete until the
page was actually finished with, we wouldn't see the problem in the
first place. I may be completely off base here.

-- 
Alex Bligh
