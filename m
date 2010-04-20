From: Li Yu <raise.sail@gmail.com>
Subject: A possible bug in reqsk_queue_hash_req()
Date: Tue, 20 Apr 2010 18:35:18 +0800
Message-ID: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

     I found out a possible bug in reqsk_queue_hash_req(), it seem
that we should move "req->dl_next = lopt->syn_table[hash];" statement
into follow write lock protected scope.

     As I browsed source code, this function only can be call at rx
code path which is protected a spin lock over struct sock , but its
caller (  inet_csk_reqsk_queue_hash_add() ) is a GPL exported symbol,
so I think that we'd best move this statement into below write lock
protected scope.

     Below is the patch to play this change, please do not apply it on
source code, it's just for show.

    Thanks.

Yu

--- include/net/request_sock.h  2010-04-09 15:27:14.000000000 +0800
+++ include/net/request_sock.h        2010-04-20 18:11:32.000000000 +0800
@@ -247,9 +247,9 @@ static inline void reqsk_queue_hash_req(
        req->expires = jiffies + timeout;
        req->retrans = 0;
        req->sk = NULL;
-       req->dl_next = lopt->syn_table[hash];

        write_lock(&queue->syn_wait_lock);
+       req->dl_next = lopt->syn_table[hash];
        lopt->syn_table[hash] = req;
        write_unlock(&queue->syn_wait_lock);
 }
