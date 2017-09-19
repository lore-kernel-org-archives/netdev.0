From: Nixiaoming <nixiaoming@huawei.com>
Subject: Re:Re: [PATCH] net/packet: fix race condition between fanout_add
 and __unregister_prot_hook
Date: Tue, 19 Sep 2017 07:50:55 +0000
Message-ID: <E490CD805F7529488761C40FD9D26EF1299D0D11@DGGEMA505-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: zh-CN
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 15, 2017 at 10:46 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>
> In case of failure we also need to unlink and free match. I
> sent the following:
>
> http://patchwork.ozlabs.org/patch/813945/

+       spin_lock(&po->bind_lock);
+       if (po->running &&
+           match->type == type &&
           match->prot_hook.type == po->prot_hook.type &&
           match->prot_hook.dev == po->prot_hook.dev) {
                err = -ENOSPC;
@@ -1761,6 +1760,13 @@  static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
                          err = 0;
                }
       }
+       spin_unlock(&po->bind_lock);
+
+       if (err && !refcount_read(&match->sk_ref)) {
+                list_del(&match->list);
+                kfree(match);
+       }


In the function fanout_add add spin_lock to protect po-> running and po-> fanout, 
then whether it should be in the function fanout_release also add spin_lock protection ?

static struct packet_fanout *fanout_release(struct sock *sk)
....
        mutex_lock(&fanout_mutex);
        f = po->fanout;
        if (f) {
                po->fanout = NULL;
