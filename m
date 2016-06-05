From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] bridge: Fix incorrect re-injection of STP
	packets
Date: Sun, 5 Jun 2016 10:40:04 +0300
Message-ID: <20160605074004.GA4491@colbert.mtl.com>
References: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, jiri@mellanox.com,
	nogahf@mellanox.com, eladr@mellanox.com, ogerlitz@mellanox.com
To: <stephen@networkplumber.org>, <davem@davemloft.net>, <fw@strlen.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Fri, Jun 03, 2016 at 12:39:45PM IDT, idosch@mellanox.com wrote:
>Commit 8626c56c8279 ("bridge: fix potential use-after-free when hook
>returns QUEUE or STOLEN verdict") fixed incorrect usage of NF_HOOK's
>return value by consuming packets in okfn via br_pass_frame_up().
>
>However, this function re-injects packets to the Rx path with skb->dev
>set to the bridge device, which breaks kernel's STP, as all STP packets
>appear to originate from the bridge device itself.
>
>Instead, if okfn was called for a packet, make bridge's rx_handler
>re-inject it to the Rx path by returning RX_HANDLER_PASS. This is
>consistent with previous behavior.
>
>Cc: Florian Westphal <fw@strlen.de>
>Fixes: 8626c56c8279 ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
>Reviewed-by: Jiri Pirko <jiri@mellanox.com>
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>

I read your commit more closely and also looked at nf_reinject() and I'm
not sure how the fix should be carried out.

After packet is processed by okfn it should return to the Rx path -
by making bridge's rx_handler return RX_HANDLER_PASS - so that it 
could be picked up by the packet handlers.

However, if verdict is NF_QUEUE and packet is later re-injected via
nf_reinject() then this can't happen, as rx_handler already returned
RX_HANDLER_CONSUMED for the packet.

So, my patch is wrong because it doesn't consume the packet in okfn, but
yours consumes it in a way which breaks current packet handlers.

Any suggestions regarding a fix? I have a feeling I'm missing something
obvious.

Thanks!
