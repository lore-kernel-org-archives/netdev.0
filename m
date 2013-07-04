From: Joe Jin <joe.jin@oracle.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 04 Jul 2013 16:55:50 +0800
Message-ID: <51D53896.1060405@oracle.com>
References: <51CBAA48.3080802@oracle.com> <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com> <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com> <1372666283.14691.8.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alex Bligh <alex@alex.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372666283.14691.8.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/01/13 16:11, Ian Campbell wrote:
> On Mon, 2013-07-01 at 11:18 +0800, Joe Jin wrote:
>>> A workaround is to turn off O_DIRECT use by Xen as that ensures
>>> the pages are copied. Xen 4.3 does this by default.
>>>
>>> I believe fixes for this are in 4.3 and 4.2.2 if using the
>>> qemu upstream DM. Note these aren't real fixes, just a workaround
>>> of a kernel bug.
>>
>> The guest is pvm, and disk model is xvbd, guest config file as below:
> 
> Do you know which disk backend? The workaround Alex refers to went into
> qdisk but I think blkback could still suffer from a variant of the
> retransmit issue if you run it over iSCSI.
> 
>>> To fix on a local build of xen you will need something like this:
>>> https://github.com/abligh/qemu-upstream-4.2-testing/commit/9a97c011e1a682eed9bc7195a25349eaf23ff3f9
>>> and something like this (NB: obviously insert your own git
>>> repo and commit numbers)
>>> https://github.com/abligh/xen/commit/f5c344afac96ced8b980b9659fb3e81c4a0db5ca
>>>
>>
>> I think this only for pvhvm/hvm?
> 
> No, the underlying issue affects any PV device which is run over a
> network protocol (NFS, iSCSI etc). In effect a delayed retransmit can
> cross over the deayed ack and cause I/O to be completed while
> retransmits are pending, such as is described in
> http://www.spinics.net/lists/linux-nfs/msg34913.html (the original NFS
> variant). The problem is that because Xen PV drivers often unmap the
> page on I/O completion you get a crash (page fault) on the retransmit.
> 

Can we do it by remember grant page refcount when mapping, and when unmap
check if page refcount as same as mapping?  This change will limited in
xen-blkback.

Another way is add new page flag like PG_send, when sendpage() be called,
set the bit, when page be put, clear the bit. Then xen-blkback can wait
on the pagequeue.

Thanks,
Joe

> The issue also affects native but in that case the symptom is "just" a
> corrupt packet on the wire. I tried to address this with my "skb
> destructor" series but unfortunately I got bogged down on the details,
> then I had to take time out to look into some other stuff and never
> managed to get back into it. I'd be very grateful if there was someone
> who could pick up that work (Alex gave some useful references in another
> reply to this thread)
> 
> Some PV disk backends (e.g. blktap2) have worked around this by using
> grant copy instead of grant map, others (e.g. qdisk) have disabled
> O_DIRECT so that the pages are copied into the dom0 page cache and
> transmitted from there.
> 
> We were discussing recently the possibility of mapping all ballooned out
> pages to a single read-only scratch page instead of leaving them empty
> in the page tables, this would cause the Xen case to revert to the
> native case. I think Thanos was going to take a look into this.
> 
> Ian.
> 


-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Senior Manager | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
