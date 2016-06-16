From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [BUG] act_ife: sleeping functions called in atomic context
Date: Thu, 16 Jun 2016 23:50:19 +0300
Message-ID: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcf_ife_init() contains a big chunk of code executed with
ife->tcf_lock spinlock held. But that code contains several calls
to sleeping functions:
  populate_metalist() and use_all_metadata()
    -> add_metainfo()
      -> find_ife_oplist(metaid)
        -> read_lock()
        -> try_module_get(o->owner)
      -> kzalloc(sizeof(*mi), GFP_KERNEL);
      -> ops->alloc(mi, metaval);
      -> module_put(ops->owner);
  _tcf_ife_cleanup()
    -> module_put()

The same problem is actual for tcf_ife_cleanup() as well.

Found by Linux Driver Verification project (linuxtesting.org).

--
Alexey Khoroshilov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
