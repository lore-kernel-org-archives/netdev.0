From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC,PATCH] mutex: mutex_is_owner() helper
Date: Wed, 04 Nov 2009 16:25:58 +0100
Message-ID: <4AF19D06.3060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux kernel <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756778AbZKDP0B@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mutex_is_locked() is called most of the time to check if mutex is locked by current
thread. But it's a lazy check, because mutex might be locked by another thread.

Adds a new mutex_is_owned_by() helper, that can check ownership if CONFIG_SMP or
CONFIG_DEBUG_MUTEXES are set.

Returns are 
 0 if mutex is unlocked.
 1 if locked
-1 if not locked by designated thread.

Last return value is possible only if CONFIG_SMP=y or CONFIG_DEBUG_MUTEXES=y

Example of use :

int rtnl_is_locked(void)
{
	return mutex_is_locked(&rtnl_mutex);
}
->
int rtnl_is_locked(void)
{
	return mutex_is_owned_by(&rtnl_mutex, current_thread_info()) == 1;
}

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/mutex-design.txt |    1 +
 include/linux/mutex.h          |   20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/Documentation/mutex-design.txt b/Documentation/mutex-design.txt
index aa60d1f..521607c 100644
--- a/Documentation/mutex-design.txt
+++ b/Documentation/mutex-design.txt
@@ -133,6 +133,7 @@ the APIs of 'struct mutex' have been streamlined:
  int  mutex_trylock(struct mutex *lock);
  void mutex_unlock(struct mutex *lock);
  int  mutex_is_locked(struct mutex *lock);
+ int  mutex_is_owned_by(struct mutex *lock, struct thread_info *ti);
  void mutex_lock_nested(struct mutex *lock, unsigned int subclass);
  int  mutex_lock_interruptible_nested(struct mutex *lock,
                                       unsigned int subclass);
diff --git a/include/linux/mutex.h b/include/linux/mutex.h
index 878cab4..95a8c5b 100644
--- a/include/linux/mutex.h
+++ b/include/linux/mutex.h
@@ -118,6 +118,26 @@ static inline int mutex_is_locked(struct mutex *lock)
 	return atomic_read(&lock->count) != 1;
 }
 
+/**
+ * mutex_is_owned_by - check mutex ownership
+ * @lock: the mutex to be queried
+ * @ti: thread_info pointer
+ *
+ * Returns: 0 if mutex is unlocked.
+ *          1 if locked
+ *         -1 if not locked by designated thread.
+ */
+static inline int mutex_is_owned_by(struct mutex *lock, struct thread_info *ti)
+{
+	if (atomic_read(&lock->count) == 1)
+		return 0;
+#if defined(CONFIG_DEBUG_MUTEXES) || defined(CONFIG_SMP)
+	if (lock->owner != ti)
+		return -1;
+#endif
+	return 1;
+}
+
 /*
  * See kernel/mutex.c for detailed documentation of these APIs.
  * Also see Documentation/mutex-design.txt.
