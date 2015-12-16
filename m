From: Courtney Cavin <courtney.cavin@sonymobile.com>
Subject: Re: [PATCH] net: add Qualcomm IPC router
Date: Wed, 16 Dec 2015 15:28:50 -0800
Message-ID: <20151216232849.GF28026@sonymobile.com>
References: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
 "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2015 at 09:41:59PM +0100, Bjorn Andersson wrote:
> From: Courtney Cavin <courtney.cavin@sonymobile.com>
> 
> Add an implementation of Qualcomm's IPC router protocol, used to
> communicate with service providing remote processors.
> 
> Signed-off-by: Courtney Cavin <courtney.cavin@sonymobile.com>
> ---
[...]
> +static int qrtr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
> +{
> +       DECLARE_SOCKADDR(struct sockaddr_qrtr *, addr, msg->msg_name);
> +       int (*enqueue_fn)(struct qrtr_node *, struct sk_buff *);
> +       struct qrtr_sock *ipc = qrtr_sk(sock->sk);
> +       struct sock *sk = sock->sk;
> +       struct qrtr_node *node;
> +       struct qrtr_hdr *hdr;
> +       struct sk_buff *skb;
> +       size_t plen;
> +       int rc;
> +
> +       if (msg->msg_flags & ~(MSG_DONTWAIT))
> +               return -EINVAL;
> +
> +       if (len > 65535)
> +               return -EMSGSIZE;
> +
> +       lock_sock(sk);
> +
> +       if (addr) {
> +               if (msg->msg_namelen < sizeof(*addr)) {
> +                       release_sock(sk);
> +                       return -EINVAL;
> +               }
> +
> +               if (addr->sq_family != AF_QIPCRTR) {
> +                       release_sock(sk);
> +                       return -EINVAL;
> +               }
> +
> +               rc = qrtr_autobind(sock);
> +               if (rc) {
> +                       release_sock(sk);
> +                       return rc;
> +               }
> +       } else if (sk->sk_state == TCP_ESTABLISHED) {
> +               addr = &ipc->peer;
> +       } else {
> +               release_sock(sk);
> +               return -ENOTCONN;
> +       }
> +
> +       node = NULL;
> +       if (addr->sq_node == QRTR_NODE_BCAST) {
> +               enqueue_fn = qrtr_bcast_enqueue;
> +       } else if (addr->sq_node == 0 || addr->sq_node == ipc->us.sq_node) {

'addr->sq_node == 0' should be removed from this if-condition.  Zero is
a valid node id.  Clients needing the local address can use
getsockname(2).

> +               enqueue_fn = qrtr_local_enqueue;
> +       } else {
> +               enqueue_fn = qrtr_node_enqueue;
> +               node = qrtr_node_lookup(addr->sq_node);
> +               if (!node) {
> +                       release_sock(sk);
> +                       return -ECONNRESET;
> +               }
> +       }

-Courtney
