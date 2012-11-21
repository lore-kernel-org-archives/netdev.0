From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] net/ipv4:  sprintf,  use "pimreg%.9u" instead of "pimreg%u".
Date: Wed, 21 Nov 2012 17:20:54 +0800
Message-ID: <50AC9CF6.2020501@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:39096 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab2KUJUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 04:20:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller:

in net/ipv4/ipmr.c:
  the mrt->id is u32 (at line 78),
  the length of name is 16 (IFNAMESIZ, line 489)
  mrt->id can be larger than 999999999, such as 4294967294 (0xffffffff - 1)
  so the len of "pimreg%u" can be 17 (pimreg4294967294'\0', line 494)

another information:
  the mrt->id is assigned in ipmr_new_table, without checking its value region (line 309)
  one calling work flow is ip_mroute_setsockopt (line 1202) -> ipmr_new_table (line 1326)
  RT_TABLE_* are as enum for mrt->id using, (include/uapi/linux/rtnetlink.h:255)

  73 struct mr_table {
  74         struct list_head        list;
  75 #ifdef CONFIG_NET_NS
  76         struct net              *net;
  77 #endif
  78         u32                     id;
  79         struct sock __rcu       *mroute_sk;
  80         struct timer_list       ipmr_expire_timer;
  81         struct list_head        mfc_unres_queue;
  82         struct list_head        mfc_cache_array[MFC_LINES];
  83         struct vif_device       vif_table[MAXVIFS];
  84         int                     maxvif;
  85         atomic_t                cache_resolve_queue_len;
  86         int                     mroute_do_assert;
  87         int                     mroute_do_pim;
  88 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
  89         int                     mroute_reg_vif_num;
  90 #endif
  91 };
 ...

 309 static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 310 {
 311         struct mr_table *mrt;
 312         unsigned int i;
 313 
 314         mrt = ipmr_get_table(net, id);
 315         if (mrt != NULL)
 316                 return mrt;
 317 
 318         mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
 319         if (mrt == NULL)
 320                 return NULL;
 321         write_pnet(&mrt->net, net);
 322         mrt->id = id;
 323 
 324         /* Forwarding cache */
 325         for (i = 0; i < MFC_LINES; i++)
 326                 INIT_LIST_HEAD(&mrt->mfc_cache_array[i]);
 327 
 328         INIT_LIST_HEAD(&mrt->mfc_unres_queue);
 329 
 330         setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
 331                     (unsigned long)mrt);
 332 
 333 #ifdef CONFIG_IP_PIMSM
 334         mrt->mroute_reg_vif_num = -1;
 335 #endif
 336 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 337         list_add_tail_rcu(&mrt->list, &net->ipv4.mr_tables);
 338 #endif
 339         return mrt;
 340 }
 341 
 ...

 485 static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 486 {
 487         struct net_device *dev;
 488         struct in_device *in_dev;
 489         char name[IFNAMSIZ];
 490 
 491         if (mrt->id == RT_TABLE_DEFAULT)
 492                 sprintf(name, "pimreg");
 493         else
 494                 sprintf(name, "pimreg%u", mrt->id);
 495 
 496         dev = alloc_netdev(0, name, reg_vif_setup);
 497 
 498         if (dev == NULL)
 499                 return NULL;
 500 
 ...

1202 int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
1203 {
1204         int ret;
1205         struct vifctl vif;
1206         struct mfcctl mfc;
1207         struct net *net = sock_net(sk);
1208         struct mr_table *mrt;
1209 
1210         mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
1211         if (mrt == NULL)
1212                 return -ENOENT;
1213 
1214         if (optname != MRT_INIT) {
1215                 if (sk != rcu_access_pointer(mrt->mroute_sk) &&
1216                     !capable(CAP_NET_ADMIN))
1217                         return -EACCES;
1218         }
1219 
1220         switch (optname) {

 ...

1311 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
1312         case MRT_TABLE:
1313         {
1314                 u32 v;
1315 
1316                 if (optlen != sizeof(u32))
1317                         return -EINVAL;
1318                 if (get_user(v, (u32 __user *)optval))
1319                         return -EFAULT;
1320 
1321                 rtnl_lock();
1322                 ret = 0;
1323                 if (sk == rtnl_dereference(mrt->mroute_sk)) {
1324                         ret = -EBUSY;
1325                 } else {
1326                         if (!ipmr_new_table(net, v))
1327                                 ret = -ENOMEM;
1328                         raw_sk(sk)->ipmr_table = v;
1329                 }
1330                 rtnl_unlock();
1331                 return ret;
1332         }
1333 #endif


in include/uapi/linux/rtnetlink.h

255 enum rt_class_t {
256         RT_TABLE_UNSPEC=0,
257 /* User defined values */
258         RT_TABLE_COMPAT=252,
259         RT_TABLE_DEFAULT=253,
260         RT_TABLE_MAIN=254,
261         RT_TABLE_LOCAL=255,
262         RT_TABLE_MAX=0xFFFFFFFF
263 };
264 
