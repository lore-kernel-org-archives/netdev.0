From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: [PATCH] net bridge: add null pointer check, fix panic
Date: Mon, 11 Nov 2013 14:27:21 +0400
Message-ID: <CAChDUfR7nXaEjgGfNBX0HiE+i66vcuCyFx3GMyOiCTwuGO=uQA@mail.gmail.com>
References: <51C2710D.2060405@gmail.com>
	<51C2721B.9050603@gmail.com>
	<1371704129.3252.356.camel@edumazet-glaptop>
	<51C2A8AA.5010902@gmail.com>
	<1371713342.3252.371.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c38dc267bf9204eae42de8
Cc: xiaoming gao <gxm.linux.kernel@gmail.com>,
	stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:39404 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab3KKK1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 05:27:23 -0500
In-Reply-To: <1371713342.3252.371.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c38dc267bf9204eae42de8
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jun 20, 2013 at 11:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-06-20 at 15:00 +0800, xiaoming gao wrote:
>
>> HI Eric
>> the problem is as follow:
>> br_del_if()-->del_nbp():
>>
>> list_del_rcu(&p->list);
>> dev->priv_flags &= ~IFF_BRIDGE_PORT;
>>
>> ------>at this point, the nic be deleting still have rx_handler , so , may in br_handle_frame()
>> ------>br_port_exists() will return false,so br_get_port_rcu() will return NULL
>> ------>so in br_handle_frame , there will be a null panic.
>>
>> netdev_rx_handler_unregister(dev);
>> synchronize_net();
>
> This code is no longer like that in current tree.
> Check commit 4a0b5ec12f0ffc3024616e6dc62cf8a04c54edcd
> ("bridge: remove a redundant synchronize_net()")
>
>>
>>
>> i have checked commit 00cfec37484761a44, i think it didn't fix this bug..
>
> I claim adding NULL tests is not needed in the fast path, it was clearly
> stated in the changelog.
>
> I would change the dismantle path to make sure br_get_port_rcu() does
> not return NULL in the fast path, and remove the test on FF_BRIDGE_PORT
> Try something like that :
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 1b8b8b8..2edfb80 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -60,7 +60,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
>  int br_handle_frame_finish(struct sk_buff *skb)
>  {
>         const unsigned char *dest = eth_hdr(skb)->h_dest;
> -       struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> +       struct net_bridge_port *p = __br_port_get_rcu(skb->dev);
>         struct net_bridge *br;
>         struct net_bridge_fdb_entry *dst;
>         struct net_bridge_mdb_entry *mdst;
> @@ -68,7 +68,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
>         bool unicast = true;
>         u16 vid = 0;
>
> -       if (!p || p->state == BR_STATE_DISABLED)
> +       if (p->state == BR_STATE_DISABLED)
>                 goto drop;
>
>         if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
> @@ -142,7 +142,7 @@ drop:
>  /* note: already called with rcu_read_lock */
>  static int br_handle_local_finish(struct sk_buff *skb)
>  {
> -       struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> +       struct net_bridge_port *p = __br_port_get_rcu(skb->dev);
>         u16 vid = 0;
>
>         br_vlan_get_tag(skb, &vid);
> @@ -172,7 +172,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>         if (!skb)
>                 return RX_HANDLER_CONSUMED;
>
> -       p = br_port_get_rcu(skb->dev);
> +       p = __br_port_get_rcu(skb->dev);
>
>         if (unlikely(is_link_local_ether_addr(dest))) {
>                 /*
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 3be89b3..9fdd467 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -184,6 +184,11 @@ struct net_bridge_port
>
>  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
>
> +static inline struct net_bridge_port *__br_port_get_rcu(const struct net_device *dev)
> +{
> +       return rcu_dereference(dev->rx_handler_data);
> +}
> +
>  static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
>  {
>         struct net_bridge_port *port =
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

> I claim adding NULL tests is not needed in the fast path, it was clearly
> stated in the changelog.

Hello,

This commit makes trouble for current STP.
Two days ago i tried to switch to 3.10.18 and i've caught "bad magic"
on uninitialized br->lock:
./net/bridge/br_stp_bpdu.c +158 in br_stp_rcv (trace attached):

        p = br_port_get_rcu(dev);

        br = p->br;
        spin_lock(&br->lock); <- here
-----------------------------------------------

 Bisect pointed to this commit
(linux-stable: 960b8e5018a552f62cfbc0dfe94be7b6ba178f13)
(mainline 716ec052d2280d511e10e90ad54a86f5b5d4dcc2)

As far as i can see this happens when:

a) bridge module had been loaded but there was no bridge interface,
br->lock had not been initialized.
b) interface had been in promiscuous mod (tcpdump)
c) stp broadcasts 01:80:c2:00:00:00 coming to this iface
   (llc_rcv drops PACKET_OTHERHOST to protect us in promiscuous mode
but seems like not a broadcasts)
d) and finally rx_handler_data had been initialised for this interface
( by macvlan in my case)

It seems like STP needs its own IFF_BRIDGE_PORT check.
probably an easiest option to check it in br_stp_rcv as before (or
probably in llc_rcv)...

-- 
Best regards.
       Alexander Y. Fomichev <git.user@gmail.com>

--001a11c38dc267bf9204eae42de8
Content-Type: application/octet-stream; name="br_stp_rcv-spin_lock.trace"
Content-Disposition: attachment; filename="br_stp_rcv-spin_lock.trace"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hnhheqv00

WyAxNzYxLjA0NTIyM10gQlVHOiBzb2Z0IGxvY2t1cCAtIENQVSM2IHN0dWNrIGZvciAyM3MhIFtt
ZDFfcmVzeW5jOjE1OTddClsgMTc2MS4wNTE3MDFdIE1vZHVsZXMgbGlua2VkIGluOiBicmlkZ2Ug
c3RwIGxsYyBtYWN2bGFuIGlwdF9SRUpFQ1QgbmZfY29ubnRyYWNrX2lwdjQgbmZfZGVmcmFnX2lw
djQgeHRfbXVsdGlwb3J0IHh0X2Nvbm50cmFjayBuZl9jb25udHJhY2sgaXB0YWJsZV9maWx0ZXIg
aXBfdGFibGVzIFtsYXN0IHVubG9hZGVkOiB4dF9vd25lcl0KWyAxNzYxLjA2ODc5NF0gaXJxIGV2
ZW50IHN0YW1wOiAyMjkwMTQ3NzIKWyAxNzYxLjA3MjU2NF0gaGFyZGlycXMgbGFzdCAgZW5hYmxl
ZCBhdCAoMjI5MDE0NzcyKTogWzxmZmZmZmZmZjgxMDNlNDkyPl0gdnByaW50a19lbWl0KzB4MWIy
LzB4NDYwClsgMTc2MS4wODE0MjBdIGhhcmRpcnFzIGxhc3QgZGlzYWJsZWQgYXQgKDIyOTAxNDc3
MSk6IFs8ZmZmZmZmZmY4MTAzZTMyND5dIHZwcmludGtfZW1pdCsweDQ0LzB4NDYwClsgMTc2MS4w
OTAxOTFdIHNvZnRpcnFzIGxhc3QgIGVuYWJsZWQgYXQgKDIyOTAxNDcwMCk6IFs8ZmZmZmZmZmY4
MTA0NDRkOD5dIF9fZG9fc29mdGlycSsweDE3OC8weDJhMApbIDE3NjEuMDk5MDQyXSBzb2Z0aXJx
cyBsYXN0IGRpc2FibGVkIGF0ICgyMjkwMTQ3NTMpOiBbPGZmZmZmZmZmODE2YWE0NGM+XSBjYWxs
X3NvZnRpcnErMHgxYy8weDMwClsgMTc2MS4xMDc3MjldIENQVTogNiBQSUQ6IDE1OTcgQ29tbTog
bWQxX3Jlc3luYyBOb3QgdGFpbnRlZCAzLjEwLjE3ICMxMwpbIDE3NjEuMTE0MTk5XSBIYXJkd2Fy
ZSBuYW1lOiBTdXBlcm1pY3JvIFg5RFJHLUhGL1g5RFJHLUhGLCBCSU9TIDEuMGMgMDgvMjIvMjAx
MgpbIDE3NjEuMTIxMzY4XSB0YXNrOiBmZmZmODgwODRmMDgwMDAwIHRpOiBmZmZmODgwODRmMDdh
MDAwIHRhc2sudGk6IGZmZmY4ODA4NGYwN2EwMDAKWyAxNzYxLjEyODkwOF0gUklQOiAwMDEwOls8
ZmZmZmZmZmY4MTMyMmM1Nz5dICBbPGZmZmZmZmZmODEzMjJjNTc+XSBkZWxheV90c2MrMHgzNy8w
eDYwClsgMTc2MS4xMzY3MjddIFJTUDogMDAxODpmZmZmODgxMDdmYzAzYWQwICBFRkxBR1M6IDAw
MDAwMjA2ClsgMTc2MS4xNDIwNzNdIFJBWDogMDAwMDAwMDAwMGRjNTZjYiBSQlg6IGZmZmZmZmZm
ODE2YTA2NWMgUkNYOiAwMDAwMDAwMDAwMDAwMDAxClsgMTc2MS4xNDkyNTBdIFJEWDogMDAwMDAw
MDAwMDFkYWEwYSBSU0k6IDAwMDAwMDAwMDBkYzU2OWYgUkRJOiAwMDAwMDAwMDAwMDAwMDAxClsg
MTc2MS4xNTY0MThdIFJCUDogZmZmZjg4MTA3ZmMwM2FkMCBSMDg6IDAwMDAwMDAwMDAwMDAwMDYg
UjA5OiAwMDAwMDAwMDAwMDAwMDAwClsgMTc2MS4xNjM1NzddIFIxMDogMDAwMDAwMDAwMDAwMDAw
MiBSMTE6IDAwMDAwMDAwMDAwMDAwMDIgUjEyOiBmZmZmODgxMDdmYzAzYTQ4ClsgMTc2MS4xNzA3
NDZdIFIxMzogZmZmZmZmZmY4MTZhOWQyZiBSMTQ6IGZmZmY4ODEwN2ZjMDNhZDAgUjE1OiAwMDAw
MDAwMDJhNTUyZTJlClsgMTc2MS4xNzc5MDNdIEZTOiAgMDAwMDAwMDAwMDAwMDAwMCgwMDAwKSBH
UzpmZmZmODgxMDdmYzAwMDAwKDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAKWyAxNzYxLjE4
NjA1MF0gQ1M6ICAwMDEwIERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMwpb
IDE3NjEuMTkxODI2XSBDUjI6IDAwMDAwMDAwMDFlMTgwMDAgQ1IzOiAwMDAwMDAwMDAxOTc0MDAw
IENSNDogMDAwMDAwMDAwMDA0MDdlMApbIDE3NjEuMTk5MDAwXSBEUjA6IDAwMDAwMDAwMDAwMDAw
MDAgRFIxOiAwMDAwMDAwMDAwMDAwMDAwIERSMjogMDAwMDAwMDAwMDAwMDAwMApbIDE3NjEuMjA2
MTU4XSBEUjM6IDAwMDAwMDAwMDAwMDAwMDAgRFI2OiAwMDAwMDAwMGZmZmYwZmYwIERSNzogMDAw
MDAwMDAwMDAwMDQwMApbIDE3NjEuMjEzMzE2XSBTdGFjazoKWyAxNzYxLjIxNjU4M10gIGZmZmY4
ODEwN2ZjMDNhZTAgZmZmZmZmZmY4MTMyMmI1ZiBmZmZmODgxMDdmYzAzYjEwIGZmZmZmZmZmODE2
OTUwYTQKWyAxNzYxLjIyNDEyNF0gIDAwMDAwMDAwMDAwMDc0NjUgZmZmZjg4MTA1MjdhODAwMCBm
ZmZmODgxMDUyN2E4MDAwIGZmZmY4ODA4NGU5NmUwMDAKWyAxNzYxLjIzMTY2Nl0gIGZmZmY4ODEw
N2ZjMDNiMzAgZmZmZmZmZmY4MTMyYjM0NCBmZmZmODgxMDRiNWMxMTgwIGZmZmY4ODEwNTI3YTgw
MDAKWyAxNzYxLjIzOTIxNF0gQ2FsbCBUcmFjZToKWyAxNzYxLjI0MTY4Nl0gIDxJUlE+ClsgMTc2
MS4yNDM2MTldICBbPGZmZmZmZmZmODEzMjJiNWY+XSBfX2RlbGF5KzB4Zi8weDIwClsgMTc2MS4y
NDg2OTNdICBbPGZmZmZmZmZmODE2OTUwYTQ+XSBfX3NwaW5fbG9ja19kZWJ1ZysweDQzLzB4N2IK
WyAxNzYxLjI1NDQ3NF0gIFs8ZmZmZmZmZmY4MTMyYjM0ND5dIGRvX3Jhd19zcGluX2xvY2srMHg0
NC8weGMwClsgMTc2MS4yNjAxNThdICBbPGZmZmZmZmZmODE2OWY5Mjk+XSBfcmF3X3NwaW5fbG9j
aysweDM5LzB4NDAKWyAxNzYxLjI2NTY4MV0gIFs8ZmZmZmZmZmZhMDA1YjNkYT5dID8gYnJfc3Rw
X3JjdisweDhhLzB4M2YwIFticmlkZ2VdClsgMTc2MS4yNzE5MDJdICBbPGZmZmZmZmZmYTAwNWIz
ZGE+XSBicl9zdHBfcmN2KzB4OGEvMHgzZjAgW2JyaWRnZV0KWyAxNzYxLjI3Nzk0MV0gIFs8ZmZm
ZmZmZmZhMDAwZTE2MD5dID8gc3RwX3Byb3RvX3JlZ2lzdGVyKzB4YjAvMHhiMCBbc3RwXQpbIDE3
NjEuMjg0NDk1XSAgWzxmZmZmZmZmZjgxNjg4OGUzPl0gPyBwcmludGsrMHg0ZC8weDRmClsgMTc2
MS4yODk0OTRdICBbPGZmZmZmZmZmODEwNDQyMTk+XSA/IGxvY2FsX2JoX2VuYWJsZSsweDg5LzB4
ZjAKWyAxNzYxLjI5NTI3NV0gIFs8ZmZmZmZmZmZhMDAwZTE2MD5dID8gc3RwX3Byb3RvX3JlZ2lz
dGVyKzB4YjAvMHhiMCBbc3RwXQpbIDE3NjEuMzAxODM0XSAgWzxmZmZmZmZmZmEwMDBlMTYwPl0g
PyBzdHBfcHJvdG9fcmVnaXN0ZXIrMHhiMC8weGIwIFtzdHBdClsgMTc2MS4zMDg0MTZdICBbPGZm
ZmZmZmZmYTAwMGUyNDg+XSBzdHBfcGR1X3JjdisweGU4LzB4ZWEwIFtzdHBdClsgMTc2MS4zMTQy
OTldICBbPGZmZmZmZmZmYTAwMGUxNjA+XSA/IHN0cF9wcm90b19yZWdpc3RlcisweGIwLzB4YjAg
W3N0cF0KWyAxNzYxLjMyMDg2OF0gIFs8ZmZmZmZmZmZhMDAzZTY2MT5dIGxsY19yY3YrMHgzNzEv
MHg0ZTAgW2xsY10KWyAxNzYxLjMyNjQ4Nl0gIFs8ZmZmZmZmZmY4MTVlZTY0Nj5dIF9fbmV0aWZf
cmVjZWl2ZV9za2JfY29yZSsweDVjNi8weDcwMApbIDE3NjEuMzMzMDQ2XSAgWzxmZmZmZmZmZjgx
NWVlMTdhPl0gPyBfX25ldGlmX3JlY2VpdmVfc2tiX2NvcmUrMHhmYS8weDcwMApbIDE3NjEuMzM5
Njk0XSAgWzxmZmZmZmZmZjgxMGEwOThmPl0gPyBfX2xvY2tfcmVsZWFzZSsweDZmLzB4MTAwClsg
MTc2MS4zNDU0NjldICBbPGZmZmZmZmZmODE1ZjIzZTE+XSBfX25ldGlmX3JlY2VpdmVfc2tiKzB4
MjEvMHg3MApbIDE3NjEuMzUxNDIxXSAgWzxmZmZmZmZmZjgxNWYyNWYzPl0gbmV0aWZfcmVjZWl2
ZV9za2IrMHgyMy8weGYwClsgMTc2MS4zNTcyMDNdICBbPGZmZmZmZmZmODEzOWYyMjA+XSA/IGRt
YV9pc3N1ZV9wZW5kaW5nX2FsbCsweGIwLzB4ZTAKWyAxNzYxLjM2MzQ5NV0gIFs8ZmZmZmZmZmY4
MTVmMzZlOD5dIG5hcGlfZ3JvX3JlY2VpdmUrMHhlOC8weDE0MApbIDE3NjEuMzY5MjgzXSAgWzxm
ZmZmZmZmZjgxNGVlMGY4Pl0gaWdiX2NsZWFuX3J4X2lycSsweDE0OC8weDFjMApbIDE3NjEuMzc1
MTQzXSAgWzxmZmZmZmZmZjgxNGVlMWNlPl0gaWdiX3BvbGwrMHg1ZS8weGEwClsgMTc2MS4zODAx
NjJdICBbPGZmZmZmZmZmODE1ZjJhMjk+XSBuZXRfcnhfYWN0aW9uKzB4MTM5LzB4MjUwClsgMTc2
MS4zODU3NjhdICBbPGZmZmZmZmZmODEwNDQ0MDk+XSA/IF9fZG9fc29mdGlycSsweGE5LzB4MmEw
ClsgMTc2MS4zOTEzNzVdICBbPGZmZmZmZmZmODEwNDQ0NTA+XSBfX2RvX3NvZnRpcnErMHhmMC8w
eDJhMApbIDE3NjEuMzk2ODI4XSAgWzxmZmZmZmZmZjgxNmFhNDRjPl0gY2FsbF9zb2Z0aXJxKzB4
MWMvMHgzMApbIDE3NjEuNDAyMTgzXSAgWzxmZmZmZmZmZjgxMDAzZTdkPl0gZG9fc29mdGlycSsw
eDhkLzB4YzAKWyAxNzYxLjQwNzM0OV0gIFs8ZmZmZmZmZmY4MTA0NDc5ZT5dIGlycV9leGl0KzB4
YWUvMHhkMApbIDE3NjEuNDEyMzUyXSAgWzxmZmZmZmZmZjgxNmFhOTkzPl0gZG9fSVJRKzB4NjMv
MHhlMApbIDE3NjEuNDE3MTc5XSAgWzxmZmZmZmZmZjgxNmEwNWFmPl0gY29tbW9uX2ludGVycnVw
dCsweDZmLzB4NmYKWyAxNzYxLjQyMjg4N10gIDxFT0k+ClsgMTc2MS40MjQ4MjFdICBbPGZmZmZm
ZmZmODExMDcyZTE+XSA/IGdldF9wYWdlX2Zyb21fZnJlZWxpc3QrMHgyNDEvMHg1ZDAKWyAxNzYx
LjQzMTYxMF0gIFs8ZmZmZmZmZmY4MTEwODFjMj5dIF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHgx
ODIvMHhhNTAKWyAxNzYxLjQzNzk4OV0gIFs8ZmZmZmZmZmY4MTA5ZmU2MT5dID8gX19sb2NrX2Fj
cXVpcmUrMHgzZjEvMHhhODAKWyAxNzYxLjQ0Mzg0OF0gIFs8ZmZmZmZmZmY4MTA2ZmJlMz5dID8g
ZmluaXNoX3Rhc2tfc3dpdGNoKzB4ODMvMHhmMApbIDE3NjEuNDQ5OTA1XSAgWzxmZmZmZmZmZjgx
MDlmZTYxPl0gPyBfX2xvY2tfYWNxdWlyZSsweDNmMS8weGE4MApbIDE3NjEuNDU1Nzk5XSAgWzxm
ZmZmZmZmZjgxMmZmYWU2Pl0gPyBpb2NfbG9va3VwX2ljcSsweDg2LzB4ZjAKWyAxNzYxLjQ2MTQ4
Nl0gIFs8ZmZmZmZmZmY4MTE5OThjMT5dID8gYmlvX2FsbG9jX2Jpb3NldCsweDE2MS8weDFjMApb
IDE3NjEuNDY3NTM2XSAgWzxmZmZmZmZmZjgxMTQyMzlhPl0gYWxsb2NfcGFnZXNfY3VycmVudCsw
eGJhLzB4MTcwClsgMTc2MS40NzM1NjhdICBbPGZmZmZmZmZmODE1NjYzYTQ+XSByMTBidWZfcG9v
bF9hbGxvYysweDE3NC8weDJjMApbIDE3NjEuNDc5NTMxXSAgWzxmZmZmZmZmZjgxMTAyNDFlPl0g
bWVtcG9vbF9hbGxvYysweDVlLzB4MTYwClsgMTc2MS40ODUwNDRdICBbPGZmZmZmZmZmODE1Njc2
YzY+XSBzeW5jX3JlcXVlc3QrMHg5MTYvMHgxMTgwClsgMTc2MS40OTA2NTBdICBbPGZmZmZmZmZm
ODE1NzBhZjE+XSA/IGlzX21kZGV2X2lkbGUrMHgxNDEvMHgxNzAKWyAxNzYxLjQ5NjQzOV0gIFs8
ZmZmZmZmZmY4MTU3MDliNT5dID8gaXNfbWRkZXZfaWRsZSsweDUvMHgxNzAKWyAxNzYxLjUwMjAz
OV0gIFs8ZmZmZmZmZmY4MTU3M2M5OD5dIG1kX2RvX3N5bmMrMHg1NDgvMHhkMTAKWyAxNzYxLjUw
NzM4NV0gIFs8ZmZmZmZmZmY4MTA2ZmJlMz5dID8gZmluaXNoX3Rhc2tfc3dpdGNoKzB4ODMvMHhm
MApbIDE3NjEuNTEzNDE4XSAgWzxmZmZmZmZmZjgxMDYzYjYwPl0gPyBfX2luaXRfd2FpdHF1ZXVl
X2hlYWQrMHg2MC8weDYwClsgMTc2MS41MTk3MjBdICBbPGZmZmZmZmZmODE1NzBkOGQ+XSBtZF90
aHJlYWQrMHgxMWQvMHgxNzAKWyAxNzYxLjUyNDk3Ml0gIFs8ZmZmZmZmZmY4MTA5ZTkxZD5dID8g
dHJhY2VfaGFyZGlycXNfb24rMHhkLzB4MTAKWyAxNzYxLjUzMDg0MF0gIFs8ZmZmZmZmZmY4MTU3
MGM3MD5dID8gbWRfcmVnaXN0ZXJfdGhyZWFkKzB4ZjAvMHhmMApbIDE3NjEuNTM2ODc5XSAgWzxm
ZmZmZmZmZjgxMDYzMDRiPl0ga3RocmVhZCsweGRiLzB4ZTAKWyAxNzYxLjU0MTc5NV0gIFs8ZmZm
ZmZmZmY4MTA2MmY3MD5dID8gX19pbml0X2t0aHJlYWRfd29ya2VyKzB4NzAvMHg3MApbIDE3NjEu
NTQ4MDk0XSAgWzxmZmZmZmZmZjgxNmE4ZjVjPl0gcmV0X2Zyb21fZm9yaysweDdjLzB4YjAKWyAx
NzYxLjU1MzUzMF0gIFs8ZmZmZmZmZmY4MTA2MmY3MD5dID8gX19pbml0X2t0aHJlYWRfd29ya2Vy
KzB4NzAvMHg3MApbIDE3NjEuNTU5ODI5XSBDb2RlOiAwNCAyNSAxYyBiMCAwMCAwMCAwZiAxZiAw
MCAwZiBhZSBlOCAwZiAzMSA4OSBjNiBlYiAxMSA2NiA5MCBmMyA5MCA2NSA4YiAwYyAyNSAxYyBi
MCAwMCAwMCA0MSAzOSBjOCA3NSAxMiAwZiAxZiAwMCAwZiBhZSBlOCAwZiAzMSA8ODk+IGMyIDI5
IGYyIDM5IGZhIDcyIGUxIDVkIGMzIDI5IGM2IDAxIGY3IDBmIDFmIDAwIDBmIGFlIGU4IDBmCg==
--001a11c38dc267bf9204eae42de8
Content-Type: application/x-download;
	name="fix_stp_bridge_uninitialized.patch"
Content-Disposition: attachment;
	filename="fix_stp_bridge_uninitialized.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hnvg9ppo1

ZGlmZiAtdXJOcCBhL25ldC9icmlkZ2UvYnJfc3RwX2JwZHUuYyBiL25ldC9icmlkZ2UvYnJfc3Rw
X2JwZHUuYwotLS0gYS9uZXQvYnJpZGdlL2JyX3N0cF9icGR1LmMJMjAxMy0xMC0xOCAyMTo0NDox
OS4wMDAwMDAwMDAgKzA0MDAKKysrIGIvbmV0L2JyaWRnZS9icl9zdHBfYnBkdS5jCTIwMTMtMTEt
MTEgMTE6MzM6MjIuNjgzNTQ5NjE2ICswNDAwCkBAIC0xNTIsMTAgKzE1MiwxMCBAQCB2b2lkIGJy
X3N0cF9yY3YoY29uc3Qgc3RydWN0IHN0cF9wcm90byAqCiAJYnVmID0gc2tiLT5kYXRhOwogCWlm
IChidWZbMF0gIT0gMCB8fCBidWZbMV0gIT0gMCB8fCBidWZbMl0gIT0gMCkKIAkJZ290byBlcnI7
CisJaWYgKCFicl9wb3J0X2V4aXN0cyhkZXYpKQorCQlnb3RvIGVycjsKIAogCXAgPSBicl9wb3J0
X2dldF9yY3UoZGV2KTsKLQlpZiAoIXApCi0JCWdvdG8gZXJyOwogCiAJYnIgPSBwLT5icjsKIAlz
cGluX2xvY2soJmJyLT5sb2NrKTsK
--001a11c38dc267bf9204eae42de8--
