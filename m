From: Benjamin Coddington <bcodding@redhat.com>
Subject: Re: [RFC] Is it a bug for nfs on udp6 mode or kernel?
Date: Wed, 13 Apr 2016 10:11:32 -0400 (EDT)
Message-ID: <alpine.OSX.2.19.9992.1604131003530.55780@planck>
References: <570E2D69.7080102@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-14952713-1460556695=:55780"
Cc: linux-nfs-approval@vger.kernel.org, tom@herbertland.com,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dhowells@redhat.com, viro@zeniv.linux.org.u, chuck.lever@oracle.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E2D69.7080102@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-14952713-1460556695=:55780
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Wed, 13 Apr 2016, Ding Tianhong wrote:

> Hi everyone:
>
> I have met this problem when I try to test udp6 for nfs connection, my environment is:
>
> Server:
> kernel: 4.1.15
> IP:xxxx::36/64
> MTU:1500
> Setting: /etc/exports:/home/nfs *(rw,sync,no_subtree_check,no_root_squash)
>
> Client:
> kernel: 4.1.18
> IP:xxxx::90/64
> MTU:1500
> command: mount -t nfs -o vers=3,proto=udp6,rsize=4096,wsize=4096 [xxxx::36]:/home/nfs /home/tmp
>
> I check the nfs parameter configuration, it looks fine and could work well for proto=tcp6.
>
> Then I have mount correctly and try to run the command "ls", it hang.
>
> When I use the rsize=1024 and wsize=1024 to mount, the problem disappeared, so I guess it is the problem for GSO or GRO for UDP。
>
> Then I try to debug the problem, first I tcpdump the package from cline to server, and found that
> the client have send readdirplus message to server correctly, and then the Server send a 4k package
> to client(the big package will frag to 4 package by GSO), till now it looks fine, and the Client Nic could
> receive the 4 skb then send to upper stack to ipv6 and udp, I found the incoming 4 package has been merged
> to one and send to upper stack just like sunrpc, but I try to open the rpc_debug, it looks that the rpc could
> not receive message.
>
>
> I built a simple demo to test the udp stack, use the client socket to send big package to server socket, it work well,
> so I think the udp is fine, maybe the bug is in sunrpc.
>
> The test is very simple, does any body met the same problem like me, thanks for any suggestion.
>
> Ding

I had a similar problem. Do you have upstream

405c92f ("ipv6: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment")
682b1a9 ("ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")

Turning off GSO and GRO caused sunrpc to work properly before this.

https://bugzilla.redhat.com/show_bug.cgi?id=1271759

Ben
--0-14952713-1460556695=:55780--
