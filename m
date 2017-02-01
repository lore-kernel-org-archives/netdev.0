From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the
 char-misc.current tree
Date: Wed, 1 Feb 2017 12:11:37 +1100
Message-ID: <20170201121137.66ee94c7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dexuan Cui <decui@microsoft.com>,
        stephen hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, Greg KH <greg@kroah.com>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/hyperv/netvsc.c

between commit:

  433e19cf33d3 ("Drivers: hv: vmbus: finally fix hv_need_to_signal_on_read()")

from the char-misc.current tree and commits:

  0b307ebd6834 ("netvsc: remove no longer needed receive staging buffers")
  46b4f7f5d1f7 ("netvsc: eliminate per-device outstanding send counter")

from the net-next tree.

I fixed it up (I think, but I have no idea what this code actually
does :-) - see below) and can carry the fix as necessary. This is now
fixed as far as linux-next is concerned, but any non trivial conflicts
should be mentioned to your upstream maintainer when your tree is
submitted for merging.  You may also want to consider cooperating with
the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/hyperv/netvsc.c
index 86e5749226ef,5cfdb1a1b4c1..000000000000
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@@ -1289,74 -1245,25 +1245,29 @@@ void netvsc_channel_cb(void *context
  	else
  		device = channel->device_obj;
  
- 	net_device = get_inbound_net_device(device);
- 	if (!net_device)
- 		return;
  	ndev = hv_get_drvdata(device);
- 	buffer = get_per_channel_state(channel);
+ 	if (unlikely(!ndev))
+ 		return;
+ 
+ 	net_device = net_device_to_netvsc_device(ndev);
+ 	if (unlikely(net_device->destroy) &&
+ 	    netvsc_channel_idle(net_device, q_idx))
+ 		return;
  
 +	/* commit_rd_index() -> hv_signal_on_read() needs this. */
 +	init_cached_read_index(channel);
 +
- 	do {
- 		desc = get_next_pkt_raw(channel);
- 		if (desc != NULL) {
- 			netvsc_process_raw_pkt(device,
- 					       channel,
- 					       net_device,
- 					       ndev,
- 					       desc->trans_id,
- 					       desc);
- 
- 			put_pkt_raw(channel, desc);
- 			need_to_commit = true;
- 			continue;
- 		}
- 		if (need_to_commit) {
- 			need_to_commit = false;
- 			commit_rd_index(channel);
- 		}
- 
- 		ret = vmbus_recvpacket_raw(channel, buffer, bufferlen,
- 					   &bytes_recvd, &request_id);
- 		if (ret == 0) {
- 			if (bytes_recvd > 0) {
- 				desc = (struct vmpacket_descriptor *)buffer;
- 				netvsc_process_raw_pkt(device,
- 						       channel,
- 						       net_device,
- 						       ndev,
- 						       request_id,
- 						       desc);
- 			} else {
- 				/*
- 				 * We are done for this pass.
- 				 */
- 				break;
- 			}
- 
- 		} else if (ret == -ENOBUFS) {
- 			if (bufferlen > NETVSC_PACKET_SIZE)
- 				kfree(buffer);
- 			/* Handle large packet */
- 			buffer = kmalloc(bytes_recvd, GFP_ATOMIC);
- 			if (buffer == NULL) {
- 				/* Try again next time around */
- 				netdev_err(ndev,
- 					   "unable to allocate buffer of size "
- 					   "(%d)!!\n", bytes_recvd);
- 				break;
- 			}
- 
- 			bufferlen = bytes_recvd;
- 		}
+ 	while ((desc = get_next_pkt_raw(channel)) != NULL) {
+ 		netvsc_process_raw_pkt(device, channel, net_device,
+ 				       ndev, desc->trans_id, desc);
  
+ 		put_pkt_raw(channel, desc);
+ 		need_to_commit = true;
 +		init_cached_read_index(channel);
+ 	}
  
- 	} while (1);
- 
- 	if (bufferlen > NETVSC_PACKET_SIZE)
- 		kfree(buffer);
+ 	if (need_to_commit)
+ 		commit_rd_index(channel);
  
  	netvsc_chk_recv_comp(net_device, channel, q_idx);
  }
