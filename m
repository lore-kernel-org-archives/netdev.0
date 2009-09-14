From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 17:06:52 +0300
Message-ID: <4AAE4DFC.9080500@voltaire.com>
References: <20090910125929.GA32593@redhat.com>	<15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>	<20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com>	<20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com> <20090914101012.GA14176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:33250 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754992AbZINOG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 10:06:59 -0400
In-Reply-To: <20090914101012.GA14176@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:
>> how  would the use case with vhost will look like?
> - Configure bridge and tun using existing scripts
> - pass tun fd to vhost via an ioctl
> - vhost calls tun_get_socket
> - from this point, guest networking just goes faster

let me see I am with you:

1. vhost gets from user space through ioctl packet socket fd OR tun fd - 
but never both

2. for packet socket fd
VM.TX is translated by vhost to sendmsg which goes through the NIC
NIC RX  makes the fd poll to signal and then recvmsg is called on the 
fd, then vhost places the packet in a virtq

3. for tun fd
VM.TX is translated by vhost to sendmsg which is translated by tun to 
netif_rx which is then handled by the bridge
NIC RX  goes to the bridge which xmits the packet a tun interface, now 
what makes tun provide this packet to vhost and how it is done?


> A lot of people have asked for tun support in vhost, because qemu currently uses tun.  With this scheme existing code and scripts can be used to configure both tun and bridge.  You also can utilize virtualization-specific features in tun.
Tun has code to support some virtualization-specific features, however, 
it has also some inherent problems, I think, for example, you don't know 
over which NIC eventually a packet will be sent and as such, the feature 
advertising to the guest (virtio-net) NIC is problematic, for example, 
TSO. With vhost, since you are directly attached to a NIC and assuming 
its a PF or VF NIC and not something like macvlan/veth you can actually 
know what features are supported by this NIC.

Or.



