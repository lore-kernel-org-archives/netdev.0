From: Antoine Martin <antoine@nagafix.co.uk>
Subject: Re: AF_VSOCK status
Date: Mon, 11 Apr 2016 18:53:05 +0700
Message-ID: <570B9021.5050709@nagafix.co.uk>
References: <5703B0F3.7050700@nagafix.co.uk>
 <20160406092609.GA17538@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nagafix.co.uk ([194.145.196.85]:53896 "EHLO
	mail.nagafix.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbcDKLxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 07:53:13 -0400
In-Reply-To: <20160406092609.GA17538@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

(snip)
> The patches are on the list (latest version sent last week): 
> http://comments.gmane.org/gmane.linux.kernel.virtualization/27455
> 
> They are only "Request For Comments" because the VIRTIO 
> specification changes have not been approved yet.  Once the spec
> is approved then the patches can be seriously considered for
> merging.
> 
> There will definitely be a v6 with Claudio Imbrenda's locking 
> fixes.
If that's any help, feel free to CC me and we'll test it.
(not sure how long I will stay subscribed to this high traffic list)

>> We now have a vsock transport merged into xpra, which works very 
>> well with the kernel and qemu versions found here: 
>> http://qemu-project.org/Features/VirtioVsock Congratulations on 
>> making this easy to use! Is the upcoming revised interface
>> likely to cause incompatibilities with existing binaries?
> 
> Userspace applications should not notice a difference.
Great.

>> It seems impossible for the host to connect to a guest: the
>> guest has to initiate the connection. Is this a feature / known 
>> limitation or am I missing something? For some of our use cases, 
>> it would be more practical to connect in the other direction.
> 
> host->guest connections have always been allowed.  I just checked 
> that it works with the latest code in my repo:
> 
> guest# nc-vsock -l 1234 host# nc-vsock 3 1234
Sorry about that, it does work fine, I must have tested it wrong.
With our latest code:
* host connecting to a guest session:
guest# xpra start --bind-vsock=auto:1234 --start-child=xterm
host# xpra attach vsock:$THECID:1234
* guest out to the host (no need for knowing the CID):
host# xpra start --bind-vsock=auto:1234 --start-child=xterm
guest# xpra attach vsock:host:1234

>> In terms of raw performance, I am getting about 10Gbps on an 
>> Intel Skylake i7 (the data stream arrives from the OS socket
>> recv syscall split into 256KB chunks), that's good but not much
>> faster than virtio-net and since the packets are avoiding all
>> sorts of OS layer overheads I was hoping to get a little bit
>> closer to the ~200Gbps memory bandwidth that this CPU+RAM are
>> capable of. Am I dreaming or just doing it wrong?
> 
> virtio-vsock is not yet optimized but the priority is not to make 
> something faster than virtio-net.  virtio-vsock is not for 
> applications who are trying to squeeze out every last drop of 
> performance.  Instead the goal is to have a transport for 
> guest<->hypervisor services that need to be zero-configuration.
Understood. It does that and this is a big win for us already, it's
also faster than virtio-net it seems, so this was not a complaint.

>> How hard would it be to introduce a virtio mmap-like transport
>> of some sort so that the guest and host could share some memory 
>> region? I assume this would give us the best possible
>> performance when transferring large amounts of data? (we already
>> have a local mmap transport we could adapt)
> 
> Shared memory is beyond the scope of virtio-vsock and it's
> unlikely to be added.
I wasn't thinking of adding this to virtio-vsock, this would be a
separate backend.

> There are a few existing ways to achieve that without involving 
> virtio-vsock: vhost-user or ivshmem.
Yes, I've looked at those and they seem a bit overkill for what we
want to achieve. We don't want sharing with multiple guests, or
interrupts.
All we want is a chunk of host memory to be accessible from the guest..

Thanks
Antoine
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlcLkBsACgkQGK2zHPGK1ruJ0wCfbNkc5L0ewUBuI7DgTyuwGRBz
aZoAn2pEbrVAkLoCMOunCYQ1FoaDIETr
=qrz1
-----END PGP SIGNATURE-----
