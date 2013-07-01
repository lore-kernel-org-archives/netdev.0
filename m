From: Joe Jin <joe.jin@oracle.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Mon, 01 Jul 2013 11:18:44 +0800
Message-ID: <51D0F514.3070309@oracle.com>
References: <51CBAA48.3080802@oracle.com> <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com> <6BFD5AF235F72F13CE646A0D@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6BFD5AF235F72F13CE646A0D@nimrod.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/30/13 17:13, Alex Bligh wrote:
> 
> 
> --On 28 June 2013 12:17:43 +0800 Joe Jin <joe.jin@oracle.com> wrote:
> 
>> Find a similar issue
>> http://www.gossamer-threads.com/lists/xen/devel/265611 So copied to Xen
>> developer as well.
> 
> I thought this sounded familiar. I haven't got the start of this
> thread, but what version of Xen are you running and what device
> model? If before 4.3, there is a page lifetime bug in the kernel
> (not the xen code) which can affect anything where the guest accesses
> the host's block stack and that in turn accesses the networking
> stack (it may in fact be wider than that). So, e.g. domU on
> iCSSI will do it. It tends to get triggered by a TCP retransmit
> or (on NFS) the RPC equivalent. Essentially block operation
> is considered complete, returning through xen and freeing the
> grant table entry, and yet something in the kernel (e.g. tcp
> retransmit) can still access the data. The nature of the bug
> is extensively discussed in that thread - you'll also find
> a reference to a thread on linux-nfs which concludes it
> isn't an nfs problem, and even some patches to fix it in the
> kernel adding reference counting.

Do you know if have a fix for above? so far we also suspected the
grant page be unmapped earlier, we using 4.1 stable during our test.

> 
> A workaround is to turn off O_DIRECT use by Xen as that ensures
> the pages are copied. Xen 4.3 does this by default.
> 
> I believe fixes for this are in 4.3 and 4.2.2 if using the
> qemu upstream DM. Note these aren't real fixes, just a workaround
> of a kernel bug.

The guest is pvm, and disk model is xvbd, guest config file as below:

vif = ['mac=00:21:f6:00:00:01,bridge=c0a80b00']
OVM_simple_name = 'Guest#1'
disk = ['file:/OVS/Repositories/0004fb000003000091e9eae94d1e907c/VirtualDisks/0004fb0000120000f78799dad800ef47.img,xvda,w', 'phy:/dev/mapper/360060e8010141870058b415700000002,xvdb,w', 'phy:/dev/mapper/360060e8010141870058b415700000003,xvdc,w']
bootargs = ''
uuid = '0004fb00-0006-0000-2b00-77a4766001ed'
on_reboot = 'restart'
cpu_weight = 27500
OVM_os_type = 'Oracle Linux 5'
cpu_cap = 0
maxvcpus = 8
OVM_high_availability = False
memory = 4096
OVM_description = ''
on_poweroff = 'destroy'
on_crash = 'restart'
bootloader = '/usr/bin/pygrub'
guest_os_type = 'linux'
name = '0004fb00000600002b0077a4766001ed'
vfb = ['type=vnc,vncunused=1,vnclisten=127.0.0.1,keymap=en-us']
vcpus = 8
OVM_cpu_compat_group = ''
OVM_domain_type = 'xen_pvm'

> 
> To fix on a local build of xen you will need something like this:
> https://github.com/abligh/qemu-upstream-4.2-testing/commit/9a97c011e1a682eed9bc7195a25349eaf23ff3f9
> and something like this (NB: obviously insert your own git
> repo and commit numbers)
> https://github.com/abligh/xen/commit/f5c344afac96ced8b980b9659fb3e81c4a0db5ca
> 

I think this only for pvhvm/hvm?


Thanks,
Joe
> Also note those fixes are (technically) unsafe for live migration
> unless there is an ordering change made in qemu's block open
> call.
> 
> Of course this might be something completely different.
> 
