From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Fri, 01 Feb 2013 09:12:22 +0100
Message-ID: <510B78E6.3000602@redhat.com>
References: <140410652.5634760.1359669990735.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <140410652.5634760.1359669990735.JavaMail.root@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

  Hi,

>> Likewise, I expect with the final version vmci_transport is a
>> separate module (or moves into the vmci driver), correct?
> 
> When you say final, do you mean something that we have to do before
> acceptance into mainline or something we can refine over time?

IMHO refining in-tree is fine.
This is the purpose of staging after all.

>From my side the minimum requirement is to have
vsock_(un)register_transport calls available, so it is possible to write
a virtio transport module without having to patch vsock code to hook it
up.  Having the vsock bits in staging would actually make it a bit
easier to add virtio.

In the end it is Greg's / Dave's call though as those have to ack &
merge the bits.

>>> +	case IOCTL_VMCI_SOCKETS_GET_LOCAL_CID:
>>> +		if (put_user(vmci_get_context_id(), p) != 0)
>>> +			retval = -EFAULT;
>>
>> What is this?
> 
> A CID, or "context ID" is how we identify a VM.  It's also in
> the address structure (svm_cid).  If you look at vm_sockets.h,
> you'll see that we have definitions for various endpoints (the
> host, anonymous and so forth).  It's sometimes useful for VMs
> to be able to query their own ID, for example, to be able to
> pass it out-of-band via INET to a peer.  So we'd like to keep
> this, although I guess it should be transport-defined, i.e.,
> we should ask the transport for this value.

Yes, should be transport specific (and optional).  virtio will (at least
initially) support guest <=> host only, so we don't need a context id.

>>> +	struct {
>>> +		/* For DGRAMs. */
>>> +		struct vmci_handle dg_handle;
>>
>> Yep, should be a pointer where transports can hook in their private
>> data.
> 
> I'm fixing this.

Yes, please, that is needed too to get started with virtio support.

>> Where is recv_dgram?
> 
> The transport just enqueues sk_buffs in the socket's buffer, so the
> core socket code can just pull them off.  So there's no explicit
> recv_dgram.

Ok.

>> Also why bind_dgram?  I guess binding stream sockets doesn't make
>> sense for the vsock family?
> 
> Ah, for our transport, there's nothing special involved in binding a
> STREAM, everything is handled by the core socket code.  So I didn't
> add a transport callback.  This is something we can add when it
> becomes necessary, if that's okay?

Sure.  Was just wondering.  TCP can bind stream sockets to interfaces to
listen -- for example -- on loopback only.  I can't see something
simliar which makes sense for vsock.

cheers,
  Gerd
