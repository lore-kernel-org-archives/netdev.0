From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Protocol handler for Marvell DSA EtherType packets
Date: Mon, 11 Feb 2008 14:18:34 +0100
Message-ID: <1202735914.20205.32.camel@localhost.localdomain>
References: <1201872514.17661.50.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-v7fK/fH/pi0aIMihBX60"
Cc: "David S. Miller" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41528 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbYBKNUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 08:20:09 -0500
In-Reply-To: <1201872514.17661.50.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v7fK/fH/pi0aIMihBX60
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi NetDev and Google,

The answer to my question was:
 Aha, you are trying to use tcpdump to see the "encapsulated" packets,
then you also need to adjust skb->mac.raw.

I have attached the code (and inlined the receive func, for easier
commenting), as I have another question:

I use dev_get_by_index() which calls dev_hold() (via my function
m88e_get_netdevice()).

The question is: 
  Should I use dev_put() before or after calling netif_rx(skb).

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


On Fri, 2008-02-01 at 14:28 +0100, Jesper Dangaard Brouer wrote:
> Hi Netdev
> 
> I writing a new protocol handler using dev_add_pack().  (For a Marvell
> switch chip handling DSA (Distributed Switch Architecture) Ethertype
> packets).
> 
> My protocol handler works and I get the skb. But I want to remove the
> DSA Headers and send the packet back for normal processing on a
> device. (I actually just want to be able to tcpdump these packets on
> the device).
> 
> I'm removing the headers by:
>   skb_pull(skb, sizeof(struct dsa_header));
> 
> I'm trying to retransmit it by:
>   netif_rx(skb);
> 
> But it seems that I just retransmit the same packet without removing
> the DSA headers.
> 
> Any hints about which functions I should use the remove the DSA header?



/*
 * 	Main DSA Receive routine.
 */
int dsa_receive(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
{
	int res = NET_RX_SUCCESS;
	struct dsa_header   *dsa_hdr;
	struct proto_header *proto_hdr;
	struct net_device   *port_dev; /* the port associated net_device*/
	struct ethhdr       *eth_hdr;

	/*
	if      (skb->pkt_type == PACKET_OTHERHOST) VERBOSE("PACKET_OTHERHOST");
	else if (skb->pkt_type == PACKET_BROADCAST) VERBOSE("PACKET_BROADCAST");
	else if (skb->pkt_type == PACKET_MULTICAST) VERBOSE("PACKET_MULTICAST");
	else if (skb->pkt_type == PACKET_HOST)      VERBOSE("PACKET_HOST");
	else VERBOSE("PACKET_TYPE UNKNOWN");
	*/

	// Access to the real mac header
	eth_hdr = (struct ethhdr *)skb->mac.raw; // Same as eth_hdr(skb)

	// At this point the Ethernet header has been removed, but the
	// DSA EtherType header contains two extra reserved bytes,
	// move the pointer past these.
	//
	// DEBUGOUT("Removing 2 reserved bytes from DSA EtherType tag");
	skb_pull(skb, 2);

	// Access to the DSA packet information
	dsa_hdr = (struct dsa_header *) skb->data;

	if (net_ratelimit()) {
		printk(KERN_INFO);
		printk("Dev:%s ",      skb->dev->name);
		printk("Type 0x%x ",   dsa_hdr->type);
		printk("Tagged 0x%x ", dsa_hdr->tagged);
//		printk("Dev 0x%x ",    dsa_hdr->dev);
		printk("Port 0x%x ",   dsa_hdr->port);
		printk("Info 0x%x ",   dsa_hdr->info);
		printk("Prio 0x%x ",   dsa_hdr->pri);
		printk("Res 0x%x ",    dsa_hdr->res);
		printk("VLAN ID 0x%x ",dsa_hdr->vid);
		printk("\n");
	}

	// Decoding the DSA type
	switch(dsa_hdr->type) {
	case DSA_TO_CPU:
	{
		int code = ((dsa_hdr->info)&0x06)|dsa_hdr->res;

		if(IGMP_TRAP == code) {
			printk("IGMP Trap\n");
		} else {
			printk("Unsupported code %d\n",code);
		}
		break;
	}
	case DSA_FROM_CPU:
		/*Fall through*/
	case DSA_TO_SNIFFER:
		/*Fall through*/
		if (net_ratelimit())
			DEBUGOUT("Sniffer packet");
		break;
	case DSA_FORWARD:
		/*Fall through*/
	default:

		break;
	}

	// Find the device associated with the switch port.
	//
	// Q: m88e_get_netdevice() calls dev_get_by_index(), which it calls dev_hold()
	port_dev = m88e_get_netdevice(dsa_hdr->port);
	skb->dev = port_dev;

	// Move past the DSA header
	skb_pull(skb, sizeof(struct dsa_header));

	// TEST: if it possible to change some skb data and see it in tcpdump
	// eth_hdr->h_proto = 0x9111;

	/* Extract the ethertype of the encapsulated packet, and
	   indicate the protocol to the next layer. */
	proto_hdr     = (struct proto_header*) skb->data;
	skb->protocol = proto_hdr->h_proto;

	if (net_ratelimit())
		printk(KERN_ERR "Encapsulated packet Protocol 0x%x\n",skb->protocol);

	// HACK, shift the mac header, this allows packet sniffers to
	// decode the packet as a normal ethernet packet, but the mac
	// address will not be correct.
	skb->mac.raw = skb->data - (6+6);

	// Q: Is it allowed to modify the skb data, I would like to
	// correct the MAC headers, but is that allowed? Do I need to
	// skb_copy the packet?

	// Move past the EtherType of the encapsulated packet
	skb_pull(skb, sizeof(struct proto_header));

	// FIXME: Perhaps we need to change skb->pkt_type to
	// PACKET_HOST, to make the next protocol handlers
	// accept/process the data???
	//skb->pkt_type = PACKET_HOST;

	// Retransmit it on a virtual switch port device... this will
	// e.g. send it to the IGMP protocol handler.
	res = netif_rx(skb);

	// Release the device pointer
	if (port_dev)
		dev_put(port_dev);

	return res;

 drop:
        kfree_skb(skb);
 out:
        return NET_RX_DROP;
}


static struct packet_type dsa_packet_type =
{
	.type = __constant_htons(ETHERTYPE_DSA),
	.dev  = NULL, /* NULL is wildcarded interfaces */
	.func = dsa_receive,
	.data = NULL,
	//.data = (void*)1, /* Set here '(void *)1' when this code can SHARE SKBs */
	.next = NULL
};


--=-v7fK/fH/pi0aIMihBX60
Content-Disposition: attachment; filename=ethertype_dsa.c
Content-Type: text/x-csrc; name=ethertype_dsa.c; charset=us-ascii
Content-Transfer-Encoding: base64

LyoNCiAqIE1hcnZlbGwgRFNBIChEaXN0cmlidXRlZCBTd2l0Y2ggQXJjaGl0ZWN0dXJlKSBFdGhl
cnR5cGUgaGFuZGxpbmcuDQogKg0KICogIFNvbWUgTWFydmVsbCBzd2l0Y2ggY2hpcHMgc3VwcG9y
dCB0byBzZW5kL3RyYXAvbWlycm9yIHNwZWNpYWwNCiAqICBwYWNrZXRzIHRvIGFub3RoZXIgc3dp
dGNoIHBvcnQuICBUaGVzZSBzcGVjaWFsIHBhY2tldHMgY2FuIGNvbnRhaW4NCiAqICBzb21lIGV4
dHJhIGluZm9ybWF0aW9uIHN0b3JlZCBpbiAod2hhdHMgY2FsbGVkKSBhIERTQSB0YWcuICBUaGUN
CiAqICBjaGlwIGFsc28gc3VwcG9ydHMgYWRkaW5nIGEgc3BlY2lhbCBFdGhlclR5cGUgaW4gZnJv
bnQgb2YgdGhlIERTQQ0KICogIHRhZywgYWxsb3dpbmcgYSBDUFUgKHdoaWNoIGF0dGFjaGVkIHRv
IG9uZSBvZiB0aGUgc3dpdGNoIHBvcnRzKQ0KICogIGVhc2llciBpZGVudGlmaWNhdGlvbiBvZiBE
U0EgZnJhbWVzLg0KICoNCiAqIENvcHlyaWdodCAoQykgSmVzcGVyIERhbmdhYXJkIEJyb3Vlciwg
VmlzaXBpYSBBcHMuDQogKg0KICoJVGhpcyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBj
YW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkNCiAqCWl0IHVuZGVyIHRoZSB0ZXJtcyBv
ZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgYXMgcHVibGlzaGVkIGJ5DQogKgl0aGUg
RnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIgdmVyc2lvbiAyIG9mIHRoZSBMaWNlbnNl
LCBvcg0KICoJKGF0IHlvdXIgb3B0aW9uKSBhbnkgbGF0ZXIgdmVyc2lvbi4NCiAqDQogKglUaGlz
IHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgdGhhdCBpdCB3aWxsIGJlIHVzZWZ1
bCwNCiAqCWJ1dCBXSVRIT1VUIEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVk
IHdhcnJhbnR5IG9mDQogKglNRVJDSEFOVEFCSUxJVFkgb3IgRklUTkVTUyBGT1IgQSBQQVJUSUNV
TEFSIFBVUlBPU0UuICBTZWUgdGhlDQogKglHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3Ig
bW9yZSBkZXRhaWxzLg0KICoNCiAqCVlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2Yg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlDQogKglhbG9uZyB3aXRoIHRoaXMgcHJvZ3Jh
bTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0d2FyZQ0KICoJRm91bmRhdGlvbiwgSW5j
LiwgNjc1IE1hc3MgQXZlLCBDYW1icmlkZ2UsIE1BIDAyMTM5LCBVU0EuDQogKg0KICogU1ZOIHZl
cnNpb24gaW5mbzoNCiAqIAkkTGFzdENoYW5nZWREYXRlOiAyMDA4LTAyLTExIDExOjExOjI4ICsw
MTAwIChNb24sIDExIEZlYiAyMDA4KSAkDQogKiAJJExhc3RDaGFuZ2VkUmV2aXNpb246IDUyMzgg
JA0KICogCSRMYXN0Q2hhbmdlZEJ5OiBqZGIgJA0KICoNCiAqLw0KDQojaW5jbHVkZSA8bGludXgv
bW9kdWxlLmg+DQojaW5jbHVkZSA8bGludXgva2VybmVsLmg+DQojaW5jbHVkZSAiZXRoZXJ0eXBl
X2RzYS5oIg0KDQojZGVmaW5lIE1PRFVMRV9OQU1FICJtODhlX0RTQSINCiNkZWZpbmUgTTg4RV9E
RUJVRyAgIDENCiNkZWZpbmUgTTg4RV9WRVJCT1NFIDENCiNpbmNsdWRlICJtODhlLmgiDQoNCiNp
Zm5kZWYgTk9USUNFIC8qIEhhbmRsZSBpZiAibTg4ZS5oIiBkZWJ1ZyBtYWNyb3MgYXJlIG5vdCBp
bmNsdWRlZCAqLw0KI2RlZmluZSBOT1RJQ0UoUykgICAgICAgICAgcHJpbnRrKEtFUk5fTk9USUNF
ICJOT1RJQ0U6ICIgUyAiXG4iKQ0KI2RlZmluZSBERUJVR09VVChTKSAgICAgICAgcHJpbnRrKEtF
Uk5fREVCVUcgUyAiXG4iKQ0KI2RlZmluZSBERUJVR09VVDEoUywgQS4uLikgcHJpbnRrKEtFUk5f
REVCVUcgUyAiXG4iLCBBKQ0KI2VuZGlmLypOT1RJQ0UqLw0KDQojaW5jbHVkZSA8bGludXgvbmV0
ZGV2aWNlLmg+IC8qIHN0cnVjdCBwYWNrZXRfdHlwZSAqLw0KI2luY2x1ZGUgPGxpbnV4L2lmX2V0
aGVyLmg+ICAvKiBzdHJ1Y3QgZXRoaGRyICovDQoNCiNpbmNsdWRlICJtODhlX2Rldi5oIiAvKiBB
Y2Nlc3MgdG8gcG9ydCBhc3NvY2lhdGVkIG5ldF9kZXZpY2UncyAqLw0KDQovKg0KIERlZmF1bHQg
RXRoZXJUeXBlIHNldCBieSBNYXJ2ZWxsIGlzIDB4OTEwMCwgdGhpcyBzaG91bGQgYmUgY2hhbmdl
ZA0KICAxKSBiZWNhdXNlIGl0cyBjb25mbGljdHMgd2l0aCBkb3VibGUtdGFnZ2luZyBvZiBWTEFO
cw0KICAyKSBiZWNhdXNlIGl0IGhpdHMgdGhlIHNhbWUgRXRoZXJUeXBlIGhhc2ggYnVja2V0IChw
dHlwZV9iYXNlKSBhcyBJUCBhbmQgVkxBTg0KKi8NCiNkZWZpbmUgRVRIRVJUWVBFX0RTQSAweDkx
MDANCg0Kc3RydWN0IHByb3RvX2hlYWRlcg0Kew0KCXVuc2lnbmVkIHNob3J0CWhfcHJvdG87CQkv
KiBwYWNrZXQgdHlwZSBJRCBmaWVsZAkqLw0KfSBfX2F0dHJpYnV0ZV9fKChwYWNrZWQpKTsNCg0K
DQovKg0KICogCU1haW4gRFNBIFJlY2VpdmUgcm91dGluZS4NCiAqLw0KaW50IGRzYV9yZWNlaXZl
KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBwYWNr
ZXRfdHlwZSAqcHQpDQp7DQoJaW50IHJlcyA9IE5FVF9SWF9TVUNDRVNTOw0KCXN0cnVjdCBkc2Ff
aGVhZGVyICAgKmRzYV9oZHI7DQoJc3RydWN0IHByb3RvX2hlYWRlciAqcHJvdG9faGRyOw0KCXN0
cnVjdCBuZXRfZGV2aWNlICAgKnBvcnRfZGV2OyAvKiB0aGUgcG9ydCBhc3NvY2lhdGVkIG5ldF9k
ZXZpY2UqLw0KCXN0cnVjdCBldGhoZHIgICAgICAgKmV0aF9oZHI7DQoNCgkvKg0KCWlmICAgICAg
KHNrYi0+cGt0X3R5cGUgPT0gUEFDS0VUX09USEVSSE9TVCkgVkVSQk9TRSgiUEFDS0VUX09USEVS
SE9TVCIpOw0KCWVsc2UgaWYgKHNrYi0+cGt0X3R5cGUgPT0gUEFDS0VUX0JST0FEQ0FTVCkgVkVS
Qk9TRSgiUEFDS0VUX0JST0FEQ0FTVCIpOw0KCWVsc2UgaWYgKHNrYi0+cGt0X3R5cGUgPT0gUEFD
S0VUX01VTFRJQ0FTVCkgVkVSQk9TRSgiUEFDS0VUX01VTFRJQ0FTVCIpOw0KCWVsc2UgaWYgKHNr
Yi0+cGt0X3R5cGUgPT0gUEFDS0VUX0hPU1QpICAgICAgVkVSQk9TRSgiUEFDS0VUX0hPU1QiKTsN
CgllbHNlIFZFUkJPU0UoIlBBQ0tFVF9UWVBFIFVOS05PV04iKTsNCgkqLw0KDQoJLy8gQWNjZXNz
IHRvIHRoZSByZWFsIG1hYyBoZWFkZXINCglldGhfaGRyID0gKHN0cnVjdCBldGhoZHIgKilza2It
Pm1hYy5yYXc7IC8vIFNhbWUgYXMgZXRoX2hkcihza2IpDQoNCgkvLyBBdCB0aGlzIHBvaW50IHRo
ZSBFdGhlcm5ldCBoZWFkZXIgaGFzIGJlZW4gcmVtb3ZlZCwgYnV0IHRoZQ0KCS8vIERTQSBFdGhl
clR5cGUgaGVhZGVyIGNvbnRhaW5zIHR3byBleHRyYSByZXNlcnZlZCBieXRlcywNCgkvLyBtb3Zl
IHRoZSBwb2ludGVyIHBhc3QgdGhlc2UuDQoJLy8NCgkvLyBERUJVR09VVCgiUmVtb3ZpbmcgMiBy
ZXNlcnZlZCBieXRlcyBmcm9tIERTQSBFdGhlclR5cGUgdGFnIik7DQoJc2tiX3B1bGwoc2tiLCAy
KTsNCg0KCS8vIEFjY2VzcyB0byB0aGUgRFNBIHBhY2tldCBpbmZvcm1hdGlvbg0KCWRzYV9oZHIg
PSAoc3RydWN0IGRzYV9oZWFkZXIgKikgc2tiLT5kYXRhOw0KDQoJaWYgKG5ldF9yYXRlbGltaXQo
KSkgew0KCQlwcmludGsoS0VSTl9JTkZPKTsNCgkJcHJpbnRrKCJEZXY6JXMgIiwgICAgICBza2It
PmRldi0+bmFtZSk7DQoJCXByaW50aygiVHlwZSAweCV4ICIsICAgZHNhX2hkci0+dHlwZSk7DQoJ
CXByaW50aygiVGFnZ2VkIDB4JXggIiwgZHNhX2hkci0+dGFnZ2VkKTsNCi8vCQlwcmludGsoIkRl
diAweCV4ICIsICAgIGRzYV9oZHItPmRldik7DQoJCXByaW50aygiUG9ydCAweCV4ICIsICAgZHNh
X2hkci0+cG9ydCk7DQoJCXByaW50aygiSW5mbyAweCV4ICIsICAgZHNhX2hkci0+aW5mbyk7DQoJ
CXByaW50aygiUHJpbyAweCV4ICIsICAgZHNhX2hkci0+cHJpKTsNCgkJcHJpbnRrKCJSZXMgMHgl
eCAiLCAgICBkc2FfaGRyLT5yZXMpOw0KCQlwcmludGsoIlZMQU4gSUQgMHgleCAiLGRzYV9oZHIt
PnZpZCk7DQoJCXByaW50aygiXG4iKTsNCgl9DQoNCgkvLyBEZWNvZGluZyB0aGUgRFNBIHR5cGUN
Cglzd2l0Y2goZHNhX2hkci0+dHlwZSkgew0KCWNhc2UgRFNBX1RPX0NQVToNCgl7DQoJCWludCBj
b2RlID0gKChkc2FfaGRyLT5pbmZvKSYweDA2KXxkc2FfaGRyLT5yZXM7DQoNCgkJaWYoSUdNUF9U
UkFQID09IGNvZGUpIHsNCgkJCXByaW50aygiSUdNUCBUcmFwXG4iKTsNCgkJfSBlbHNlIHsNCgkJ
CXByaW50aygiVW5zdXBwb3J0ZWQgY29kZSAlZFxuIixjb2RlKTsNCgkJfQ0KCQlicmVhazsNCgl9
DQoJY2FzZSBEU0FfRlJPTV9DUFU6DQoJCS8qRmFsbCB0aHJvdWdoKi8NCgljYXNlIERTQV9UT19T
TklGRkVSOg0KCQkvKkZhbGwgdGhyb3VnaCovDQoJCWlmIChuZXRfcmF0ZWxpbWl0KCkpDQoJCQlE
RUJVR09VVCgiU25pZmZlciBwYWNrZXQiKTsNCgkJYnJlYWs7DQoJY2FzZSBEU0FfRk9SV0FSRDoN
CgkJLypGYWxsIHRocm91Z2gqLw0KCWRlZmF1bHQ6DQoNCgkJYnJlYWs7DQoJfQ0KDQoJLy8gRmlu
ZCB0aGUgZGV2aWNlIGFzc29jaWF0ZWQgd2l0aCB0aGUgc3dpdGNoIHBvcnQuDQoJcG9ydF9kZXYg
PSBtODhlX2dldF9uZXRkZXZpY2UoZHNhX2hkci0+cG9ydCk7DQoJc2tiLT5kZXYgPSBwb3J0X2Rl
djsNCg0KCS8vIE1vdmUgcGFzdCB0aGUgRFNBIGhlYWRlcg0KCXNrYl9wdWxsKHNrYiwgc2l6ZW9m
KHN0cnVjdCBkc2FfaGVhZGVyKSk7DQoNCgkvLyBURVNUOiBpZiBpdCBwb3NzaWJsZSB0byBjaGFu
Z2Ugc29tZSBza2IgZGF0YSBhbmQgc2VlIGl0IGluIHRjcGR1bXANCgkvLyBldGhfaGRyLT5oX3By
b3RvID0gMHg5MTExOw0KDQoJLyogRXh0cmFjdCB0aGUgZXRoZXJ0eXBlIG9mIHRoZSBlbmNhcHN1
bGF0ZWQgcGFja2V0LCBhbmQNCgkgICBpbmRpY2F0ZSB0aGUgcHJvdG9jb2wgdG8gdGhlIG5leHQg
bGF5ZXIuICovDQoJcHJvdG9faGRyICAgICA9IChzdHJ1Y3QgcHJvdG9faGVhZGVyKikgc2tiLT5k
YXRhOw0KCXNrYi0+cHJvdG9jb2wgPSBwcm90b19oZHItPmhfcHJvdG87DQoNCglpZiAobmV0X3Jh
dGVsaW1pdCgpKQ0KCQlwcmludGsoS0VSTl9FUlIgIkVuY2Fwc3VsYXRlZCBwYWNrZXQgUHJvdG9j
b2wgMHgleFxuIixza2ItPnByb3RvY29sKTsNCg0KCS8vIEhBQ0ssIHNoaWZ0IHRoZSBtYWMgaGVh
ZGVyLCB0aGlzIGFsbG93cyBwYWNrZXQgc25pZmZlcnMgdG8NCgkvLyBkZWNvZGUgdGhlIHBhY2tl
dCBhcyBhIG5vcm1hbCBldGhlcm5ldCBwYWNrZXQsIGJ1dCB0aGUgbWFjDQoJLy8gYWRkcmVzcyB3
aWxsIG5vdCBiZSBjb3JyZWN0Lg0KCXNrYi0+bWFjLnJhdyA9IHNrYi0+ZGF0YSAtICg2KzYpOw0K
DQoJLy8gUTogSXMgaXQgYWxsb3dlZCB0byBtb2RpZnkgdGhlIHNrYiBkYXRhLCBJIHdvdWxkIGxp
a2UgdG8NCgkvLyBjb3JyZWN0IHRoZSBNQUMgaGVhZGVycywgYnV0IGlzIHRoYXQgYWxsb3dlZD8g
RG8gSSBuZWVkIHRvDQoJLy8gc2tiX2NvcHkgdGhlIHBhY2tldD8NCg0KCS8vIE1vdmUgcGFzdCB0
aGUgRXRoZXJUeXBlIG9mIHRoZSBlbmNhcHN1bGF0ZWQgcGFja2V0DQoJc2tiX3B1bGwoc2tiLCBz
aXplb2Yoc3RydWN0IHByb3RvX2hlYWRlcikpOw0KDQoJLy8gRklYTUU6IFBlcmhhcHMgd2UgbmVl
ZCB0byBjaGFuZ2Ugc2tiLT5wa3RfdHlwZSB0bw0KCS8vIFBBQ0tFVF9IT1NULCB0byBtYWtlIHRo
ZSBuZXh0IHByb3RvY29sIGhhbmRsZXJzDQoJLy8gYWNjZXB0L3Byb2Nlc3MgdGhlIGRhdGE/Pz8N
CgkvL3NrYi0+cGt0X3R5cGUgPSBQQUNLRVRfSE9TVDsNCg0KCS8vIFJldHJhbnNtaXQgaXQgb24g
YSB2aXJ0dWFsIHN3aXRjaCBwb3J0IGRldmljZS4uLiB0aGlzIHdpbGwNCgkvLyBlLmcuIHNlbmQg
aXQgdG8gdGhlIElHTVAgcHJvdG9jb2wgaGFuZGxlci4NCglyZXMgPSBuZXRpZl9yeChza2IpOw0K
DQoJLy8gUmVsZWFzZSB0aGUgZGV2aWNlIHBvaW50ZXINCglpZiAocG9ydF9kZXYpDQoJCWRldl9w
dXQocG9ydF9kZXYpOw0KDQoJcmV0dXJuIHJlczsNCg0KIGRyb3A6DQogICAgICAgIGtmcmVlX3Nr
Yihza2IpOw0KIG91dDoNCiAgICAgICAgcmV0dXJuIE5FVF9SWF9EUk9QOw0KfQ0KDQoNCnN0YXRp
YyBzdHJ1Y3QgcGFja2V0X3R5cGUgZHNhX3BhY2tldF90eXBlID0NCnsNCgkudHlwZSA9IF9fY29u
c3RhbnRfaHRvbnMoRVRIRVJUWVBFX0RTQSksDQoJLmRldiAgPSBOVUxMLCAvKiBOVUxMIGlzIHdp
bGRjYXJkZWQgaW50ZXJmYWNlcyAqLw0KCS5mdW5jID0gZHNhX3JlY2VpdmUsDQoJLmRhdGEgPSBO
VUxMLA0KCS8vLmRhdGEgPSAodm9pZCopMSwgLyogU2V0IGhlcmUgJyh2b2lkICopMScgd2hlbiB0
aGlzIGNvZGUgY2FuIFNIQVJFIFNLQnMgKi8NCgkubmV4dCA9IE5VTEwNCn07DQoNCnZvaWQgZHNh
X3JlZ2lzdGVyX2hhbmRsZXIodm9pZCkNCnsNCgkvLyBPbmx5IHByb2Nlc3MgRFNBIHBhY2tldHMg
b24gQ1BVIHRvIHN3aXRjaCBkZXZpY2UsIHRyeWluZyB0bw0KCS8vIGF2b2lkIGxvb3BzLg0KCWRz
YV9wYWNrZXRfdHlwZS5kZXYgPSBkZXZfZ2V0X2J5X25hbWUoIml4cDEiKTsNCg0KCS8vIFRPRE86
IEluY3JlYXNlIHRoZSBNVFUgb24gdGhlIHJlY2VpdmluZyBkZXZpY2UsIHRoZSBEU0ENCgkvLyBF
dGhlclR5cGUgaXMgNCBieXRlcyBhbmQgdGhlIERTQSBpbmZvIGlzIDQgYnl0ZXMuDQoNCglOT1RJ
Q0UoIlJlZ2lzdGVyOiBEU0EgRXRoZXJUeXBlIHBhY2tldCBoYW5kbGVyIik7DQoJZGV2X2FkZF9w
YWNrKCZkc2FfcGFja2V0X3R5cGUpOw0KfQ0KDQp2b2lkIGRzYV91bnJlZ2lzdGVyX2hhbmRsZXIo
dm9pZCkNCnsNCglOT1RJQ0UoIlVucmVnaXN0ZXI6IERTQSBFdGhlclR5cGUgcGFja2V0IGhhbmRs
ZXIiKTsNCglkZXZfcmVtb3ZlX3BhY2soJmRzYV9wYWNrZXRfdHlwZSk7DQp9DQo=


--=-v7fK/fH/pi0aIMihBX60
Content-Disposition: attachment; filename=ethertype_dsa.h
Content-Type: text/x-chdr; name=ethertype_dsa.h; charset=us-ascii
Content-Transfer-Encoding: base64

LyoNCiAqIE1hcnZlbGwgRFNBIChEaXN0cmlidXRlZCBTd2l0Y2ggQXJjaGl0ZWN0dXJlKSBFdGhl
cnR5cGUgaGFuZGxpbmcuDQogKg0KICogQ29weXJpZ2h0IChDKSBKZXNwZXIgRGFuZ2FhcmQgQnJv
dWVyLCBWaXNpcGlhIEFwcy4NCiAqDQogKglUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsg
eW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeQ0KICoJaXQgdW5kZXIgdGhlIHRl
cm1zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhcyBwdWJsaXNoZWQgYnkNCiAq
CXRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb247IGVpdGhlciB2ZXJzaW9uIDIgb2YgdGhlIExp
Y2Vuc2UsIG9yDQogKgkoYXQgeW91ciBvcHRpb24pIGFueSBsYXRlciB2ZXJzaW9uLg0KICoNCiAq
CVRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUgaG9wZSB0aGF0IGl0IHdpbGwgYmUg
dXNlZnVsLA0KICoJYnV0IFdJVEhPVVQgQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGlt
cGxpZWQgd2FycmFudHkgb2YNCiAqCU1FUkNIQU5UQUJJTElUWSBvciBGSVRORVNTIEZPUiBBIFBB
UlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUNCiAqCUdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNl
IGZvciBtb3JlIGRldGFpbHMuDQogKg0KICoJWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29w
eSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UNCiAqCWFsb25nIHdpdGggdGhpcyBw
cm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlDQogKglGb3VuZGF0aW9u
LCBJbmMuLCA2NzUgTWFzcyBBdmUsIENhbWJyaWRnZSwgTUEgMDIxMzksIFVTQS4NCiAqDQogKiBT
Vk4gdmVyc2lvbiBpbmZvOg0KICogCSRMYXN0Q2hhbmdlZERhdGU6IDIwMDgtMDItMTEgMTE6MTE6
MjggKzAxMDAgKE1vbiwgMTEgRmViIDIwMDgpICQNCiAqIAkkTGFzdENoYW5nZWRSZXZpc2lvbjog
NTIzOCAkDQogKiAJJExhc3RDaGFuZ2VkQnk6IGpkYiAkDQogKg0KICovDQoNCg0KI2lmbmRlZiBf
ZXRoZXJ0eXBlX2RzYV9IXw0KI2RlZmluZSBfZXRoZXJ0eXBlX2RzYV9IXw0KDQojaW5jbHVkZSA8
bGludXgvdHlwZXMuaD4NCiNpbmNsdWRlIDxhc20vYnl0ZW9yZGVyLmg+DQoNCnN0cnVjdCBkc2Ff
aGVhZGVyIHsNCglfX3U4ICB0eXBlOjIsDQoJICAgICAgdGFnZ2VkOjEsDQoJICAgICAgZGV2OjU7
DQoJX191OCAgcG9ydDo1LA0KCSAgICAgIGluZm86MzsgLy8gRGVjb2RpbmcgZGVwZW5kZW50IG9u
IHR5cGUNCiNpZiBkZWZpbmVkKF9fQklHX0VORElBTl9CSVRGSUVMRCkNCglfX3UxNiBwcmk6MywN
CgkgICAgICByZXM6MSwNCgkgICAgICB2aWQ6MTI7DQojZWxpZiBkZWZpbmVkKF9fTElUVExFX0VO
RElBTl9CSVRGSUVMRCkNCiNlcnJvcgkiTm90IGRlZmluZWQgZm9yIExpdHRsZSBFbmRpYW4gQ1BV
cyINCiNlbHNlDQojZXJyb3IJIkFkanVzdCB5b3VyIDxhc20vYnl0ZW9yZGVyLmg+IGRlZmluZXMi
DQojZW5kaWYNCn07DQoNCi8vIERTQSBUYWcgVHlwZXMNCmVudW0gew0KCURTQV9UT19DUFUgICAg
ID0gMHgwLCAvLyBiMDANCglEU0FfRlJPTV9DUFUgICA9IDB4MSwgLy8gYjAxDQoJRFNBX1RPX1NO
SUZGRVIgPSAweDIsIC8vIGIxMA0KCURTQV9GT1JXQVJEICAgID0gMHgzLCAvLyBiMTENCn07DQoN
Ci8vIERTQV9UT19DUFUgU3VwcG9ydCBjb2Rlcw0KZW51bSB7DQogICAgICAgIEJEUFVfVFJBUCAg
ICAgICAgICA9IDB4MCwgLy8gYjAwMA0KCUZSQU1FMlJFR19SRVNQT05TRSA9IDB4MSwgLy8gYjAw
MQ0KCUlHTVBfVFJBUCAgICAgICAgICA9IDB4MiwgLy8gYjAxMA0KCVBPTElDWV9UUkFQICAgICAg
ICA9IDB4MywgLy8gYjAxMQ0KCUFSUF9NSVJST1IgICAgICAgICA9IDB4NCwgLy8gYjEwMA0KCVBP
TElDWV9NSVJST1IgICAgICA9IDB4NSwgLy8gYjEwMQ0KfTsNCg0KDQpleHRlcm4gdm9pZCBkc2Ff
cmVnaXN0ZXJfaGFuZGxlciAgKHZvaWQpOw0KZXh0ZXJuIHZvaWQgZHNhX3VucmVnaXN0ZXJfaGFu
ZGxlcih2b2lkKTsNCg0KI2VuZGlmDQo=


--=-v7fK/fH/pi0aIMihBX60--
