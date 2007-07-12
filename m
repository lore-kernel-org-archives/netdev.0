From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 07:47:52 +0200
Message-ID: <4695C088.7000606@s5r6.in-berlin.de>
References: <200707101641.17672.yinghai.lu@sun.com> <200707101652.31378.yinghai.lu@sun.com> <4694B702.2050507@s5r6.in-berlin.de> <20070711210833.GA22745@kroah.com> <46954B92.8000407@sun.com> <46959651.1050400@s5r6.in-berlin.de> <4695998C.8090100@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai.Lu@Sun.COM
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758766AbXGLFsj@vger.kernel.org>
In-Reply-To: <4695998C.8090100@sun.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> Stefan Richter wrote:
>> Yinghai Lu wrote:
>>> original default is -1, and this patch just try to use parent's node as
>>> default.
>>
>> But in many cases, the patch does so at a time when the parent is not
>> yet known.
> then it will use -1.

Yes.

The patch does nothing for all subsystems which do

	device_initialize(&dev);
	dev->parent = pd;
	device_add(&dev);

Let's avoid to add infrastructure which does nothing, or only does
something by accident.

The alternatives are:

  - Change all subsystems to set dev->parent before device_initialize().
    *Document* that the device_initialize() API has this requirement.
    This is counter-intuitive, amounts to some work across the kernel,
    and could be gotten wrong again in future code because it's a
    counter-intuitive API.

  - Move your code from device_initialize() to device_add().  One minor
    drawback is that node-specific allocations based on the device's
    numa_node would not be optimized before device_add(), but there is
    probably no need for this.  Driver probes come after device_add().

  - Let subsystems explicitly call set_dev_node() on their own.

Also keep in mind that either device_move() should update the numa_node,
or the subsystems which call device_move() should explicitly update it
on their own.   (Unless they know that their devices will always stay at
the same NUMA node even when switching parents.)
-- 
Stefan Richter
-=====-=-=== -=== -==--
http://arcgraph.de/sr/
