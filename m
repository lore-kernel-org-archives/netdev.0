From: Daniel Andersson Tenninge <daniel.andersson.tenninge@ericsson.com>
Subject: virtio_net: doesn't free last skb in tx buffer
Date: Wed, 22 Jan 2014 15:02:20 +0100
Message-ID: <52DFCF6C.2080004@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	UABFRA <anders.franzen@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:54405 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752549AbaAVORY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 09:17:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been chasing a fault when closing a network namespace with a soft 
device in (vlan, macvlan, ...) and the "real" device is a virtio device. 
I couldn't decide if I should email the netdev or virtualization list 
but I hope it is sent right.

The problem is that the namespace can never close because there is a 
neighbour entry holding a reference to the device. This neighbour entry 
is not free:d since a dst_entry is left with a reference to it and this 
dst_entry is referenced from the last sk_buff sent on the virtio device.

 From the code it looks like whenever a sk_buff should be sent in the 
start_xmit (driver/net/virtio_net.c) function the driver checks the tx 
ring buffer if there are any old sk_buff there that should be free:d. 
When the network namespace is closed down the last sk_buff cannot be 
free:d until another is sent and if this doesn't happen the namespace 
will hang forever.

Now this could be done in the net_device_ops ndo_uninit, but it seems 
like if the there is a device on top of the virtio device, e.g. a vlan 
device, the ndo_uninit is called for the vlan but the vlan never passes 
it down to the real_dev. The same can be seen in the macvlan driver as 
well. Is it made like this intentional and in that case what is the 
preferred way for a device driver to clean up stuff during network 
namespace shutdown?

Wouldn't this cause a more generic problem for network device drivers 
that expect to be able to clean up stuff in ndo_uninit or is this not 
meant to be used for this and the problem is specific to the virtio_net 
leaving data after start_xmit returns?

BR,
--Daniel
