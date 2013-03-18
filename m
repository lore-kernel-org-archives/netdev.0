From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: Batch cleanup
Date: Mon, 18 Mar 2013 17:33:02 +0800
Message-ID: <5146DF4E.9030609@cn.fujitsu.com>
References: <1363254014-10725-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@openvz.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1363254014-10725-1-git-send-email-vdavydov@parallels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/03/14 17:40, Vladimir Davydov wrote:
> The patch introduces nf_conntrack_cleanup_net_list(), which cleanups
> nf_conntrack for a list of netns and calls synchronize_net() only once
> for them all. This should reduce netns destruction time.
> --
> I've measured cleanup time for 1k dummy net ns. Here are the results:
> 
>  <without the patch>
>  # modprobe nf_conntrack
>  # time modprobe -r nf_conntrack
> 
>  real	0m10.337s
>  user	0m0.000s
>  sys	0m0.376s
> 
>  <with the patch>
>  # modprobe nf_conntrack
>  # time modprobe -r nf_conntrack
> 
>  real    0m5.661s
>  user    0m0.000s
>  sys     0m0.216s
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  include/net/netfilter/nf_conntrack_core.h |    1 +
>  net/netfilter/nf_conntrack_core.c         |   46 ++++++++++++++++++++---------
>  net/netfilter/nf_conntrack_standalone.c   |   16 ++++++----
>  3 files changed, 43 insertions(+), 20 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
> index 930275f..fb2b623 100644
> --- a/include/net/netfilter/nf_conntrack_core.h
> +++ b/include/net/netfilter/nf_conntrack_core.h
> @@ -27,6 +27,7 @@ extern unsigned int nf_conntrack_in(struct net *net,
>  
>  extern int nf_conntrack_init_net(struct net *net);
>  extern void nf_conntrack_cleanup_net(struct net *net);
> +extern void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list);
>  
>  extern int nf_conntrack_proto_pernet_init(struct net *net);
>  extern void nf_conntrack_proto_pernet_fini(struct net *net);
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index c8e001a..09c02ef 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1364,30 +1364,48 @@ void nf_conntrack_cleanup_end(void)
>   */
>  void nf_conntrack_cleanup_net(struct net *net)
>  {
> +	LIST_HEAD(single);
> +
> +	list_add(&net->exit_list, &single);
> +	nf_conntrack_cleanup_net_list(&single);
> +}
> +

After adding net->exit_list to this single list,in setup_net we will
re-add this net->exit_list to net_exit_list. So there has no invalid
pointer problem.

This patch looks good to me.
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>

Thanks!
