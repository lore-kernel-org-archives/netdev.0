From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the
 driver-core.current tree
Date: Wed, 20 Sep 2017 11:15:56 +1000
Message-ID: <20170920111556.3c739e52@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  lib/kobject_uevent.c

between commit:

  6878e7de6af7 ("driver core: suppress sending MODALIAS in UNBIND uevents")

from the driver-core.current tree and commit:

  16dff336b33d ("kobject: add kobject_uevent_net_broadcast()")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc lib/kobject_uevent.c
index f237a09a5862,147db91c10d0..000000000000
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@@ -294,26 -294,55 +294,75 @@@ static void cleanup_uevent_env(struct s
  }
  #endif
  
 +static void zap_modalias_env(struct kobj_uevent_env *env)
 +{
 +	static const char modalias_prefix[] = "MODALIAS=";
 +	int i;
 +
 +	for (i = 0; i < env->envp_idx;) {
 +		if (strncmp(env->envp[i], modalias_prefix,
 +			    sizeof(modalias_prefix) - 1)) {
 +			i++;
 +			continue;
 +		}
 +
 +		if (i != env->envp_idx - 1)
 +			memmove(&env->envp[i], &env->envp[i + 1],
 +				sizeof(env->envp[i]) * env->envp_idx - 1);
 +
 +		env->envp_idx--;
 +	}
 +}
 +
+ static int kobject_uevent_net_broadcast(struct kobject *kobj,
+ 					struct kobj_uevent_env *env,
+ 					const char *action_string,
+ 					const char *devpath)
+ {
+ 	int retval = 0;
+ #if defined(CONFIG_NET)
+ 	struct sk_buff *skb = NULL;
+ 	struct uevent_sock *ue_sk;
+ 
+ 	/* send netlink message */
+ 	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
+ 		struct sock *uevent_sock = ue_sk->sk;
+ 
+ 		if (!netlink_has_listeners(uevent_sock, 1))
+ 			continue;
+ 
+ 		if (!skb) {
+ 			/* allocate message with the maximum possible size */
+ 			size_t len = strlen(action_string) + strlen(devpath) + 2;
+ 			char *scratch;
+ 
+ 			retval = -ENOMEM;
+ 			skb = alloc_skb(len + env->buflen, GFP_KERNEL);
+ 			if (!skb)
+ 				continue;
+ 
+ 			/* add header */
+ 			scratch = skb_put(skb, len);
+ 			sprintf(scratch, "%s@%s", action_string, devpath);
+ 
+ 			skb_put_data(skb, env->buf, env->buflen);
+ 
+ 			NETLINK_CB(skb).dst_group = 1;
+ 		}
+ 
+ 		retval = netlink_broadcast_filtered(uevent_sock, skb_get(skb),
+ 						    0, 1, GFP_KERNEL,
+ 						    kobj_bcast_filter,
+ 						    kobj);
+ 		/* ENOBUFS should be handled in userspace */
+ 		if (retval == -ENOBUFS || retval == -ESRCH)
+ 			retval = 0;
+ 	}
+ 	consume_skb(skb);
+ #endif
+ 	return retval;
+ }
+ 
  /**
   * kobject_uevent_env - send an uevent with environmental data
   *
