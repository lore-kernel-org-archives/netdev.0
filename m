From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2 net-next 2/2] RDS-TCP: Support multiple RDS-TCP listen
 endpoints, one per netns.
Date: Tue, 4 Aug 2015 21:26:48 -0700
Message-ID: <CAHA+R7Njnb8DZOq6dF7sktFgQYOOAY+JiiToh62B2C9SXroO3g@mail.gmail.com>
References: <cover.1438612466.git.sowmini.varadhan@oracle.com>
	<7f379a49e32abfe8e910db1a55114cce1a413c61.1438612466.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	chien.yen@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7f379a49e32abfe8e910db1a55114cce1a413c61.1438612466.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 3, 2015 at 10:29 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> +static struct pernet_operations rds_tcp_net_ops = {
> +       .init = rds_tcp_init_net,
> +       .exit = rds_tcp_exit_net,
> +       .id = &rds_tcp_netid,
> +       .size = sizeof(struct rds_tcp_net),
> +};
> +
> +static void rds_tcp_kill_sock(struct net *net)
> +{
> +       struct rds_tcp_connection *tc, *_tc;
> +       struct sock *sk;
> +       struct list_head tmp_list;
> +       struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> +
> +       rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
> +       rtn->rds_tcp_listen_sock = NULL;
> +       flush_work(&rtn->rds_tcp_accept_w);
> +       INIT_LIST_HEAD(&tmp_list);

Can be folded as LIST_HEAD(tmp_list).


> +       spin_lock_irq(&rds_tcp_conn_lock);
> +       list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
> +               struct net *c_net = read_pnet(&tc->conn->c_net);
> +
> +               if (net != c_net || !tc->t_sock)
> +                       continue;
> +               list_del(&tc->t_tcp_node);
> +               list_add_tail(&tc->t_tcp_node, &tmp_list);

list_move_tail().


> +       }
> +       spin_unlock_irq(&rds_tcp_conn_lock);
> +       list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node) {
> +               sk = tc->t_sock->sk;
> +               sk->sk_prot->disconnect(sk, 0);
> +               tcp_done(sk);
> +               if (tc->conn->c_passive)
> +                       rds_conn_destroy(tc->conn->c_passive);
> +               rds_conn_destroy(tc->conn);
> +       }
> +}
> +
> +static int rds_tcp_dev_event(struct notifier_block *this,
> +                            unsigned long event, void *ptr)
> +{
> +       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> +
> +       /* rds-tcp registers as a pernet subys, so the ->exit will only
> +        * get invoked after network acitivity has quiesced. We need to
> +        * clean up all sockets  to quiesce network activity, and use
> +        * the unregistration of the per-net loopback device as a trigger
> +        * to start that cleanup.
> +        */
> +       if (event == NETDEV_UNREGISTER_FINAL &&
> +           strcmp(dev->name, "lo") == 0)


Shouldn't check device name, check ->ifindex == LOOPBACK_IFINDEX
instead.


> +               rds_tcp_kill_sock(dev_net(dev));
> +
> +       return NOTIFY_DONE;
> +}
> +

...
