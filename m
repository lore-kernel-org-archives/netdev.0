From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH RFC 0/4] ARM/KGDB: Some fixes for SMP
	machines
Date: Wed, 7 Jul 2010 21:54:06 +0400
Message-ID: <20100707175406.GA28424@oksana.dev.rtsoft.ru>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Jason Wessel <jason.wessel@windriver.com>
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2010 at 09:12:22PM +0400, Anton Vorontsov wrote:
[...] 
> 2. The patches are against a heavily patched kernel, and so far
>    I didn't rebase them onto the 'debug core' rework as found
>    in the very latest mainline kernels. I'll rebase the patches
>    soon, so for now this is just an RFC.

BTW, I'm testing with another small fixup applied, I didn't send
it as a patch because this deadlock was already fixed in the
debug_core implementation (which KGDB is using nowadays). But
for the completeness, here it is:

(Don't deadlock if there's a wannabe-master CPUs, which entered
KGDB via exception, not NMI/IPI).

diff --git a/kernel/kgdb.c b/kernel/kgdb.c
index e7a2274..65bf75d 100644
--- a/kernel/kgdb.c
+++ b/kernel/kgdb.c
@@ -1522,7 +1522,9 @@ return_normal:
 		 * from the debugger.
 		 */
 		for_each_online_cpu(i) {
-			while (atomic_read(&cpu_in_kgdb[i]))
+			while (atomic_read(&cpu_in_kgdb[i]) &&
+					!(kgdb_info[i].exception_state &
+						DCPU_WANT_MASTER))
 				cpu_relax();
 		}
 	}

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
