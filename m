From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH v3] audit: use proper refcount locking on audit_sock
Date: Tue, 13 Dec 2016 15:50:18 -0500
Message-ID: <CAHC9VhSpMKS+9mDRiS2ekpJWCKsVSZGgJV-3v_T2+9D7PNGUnA@mail.gmail.com>
References: <20161212100215.GA1305@madcap2.tricolour.ca>
	<61c37ca790bc11bc023aea8f9b70ab3098aa30f5.1481626466.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, edumazet@google.com,
        linux-audit@redhat.com, xiyou.wangcong@gmail.com, dvyukov@google.com
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <61c37ca790bc11bc023aea8f9b70ab3098aa30f5.1481626466.git.rgb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 10:03 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> Resetting audit_sock appears to be racy.
>
> audit_sock was being copied and dereferenced without using a refcount on
> the source sock.
>
> Bump the refcount on the underlying sock when we store a refrence in
> audit_sock and release it when we reset audit_sock.  audit_sock
> modification needs the audit_cmd_mutex.
>
> See: https://lkml.org/lkml/2016/11/26/232
>
> Thanks to Eric Dumazet <edumazet@google.com> and Cong Wang
> <xiyou.wangcong@gmail.com> on ideas how to fix it.
>
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> ---
> There has been a lot of change in the audit code that is about to go
> upstream to address audit queue issues.  This patch is based on the
> source tree: git://git.infradead.org/users/pcmoore/audit#next
> ---
>  kernel/audit.c |   28 +++++++++++++++++++++++-----
>  1 files changed, 23 insertions(+), 5 deletions(-)

This looks more reasonable.  I still wonder about synchronization
between threads changing the audit_* connection variables and the
kauditd_thread, but I guess we can treat that as another issue; this
patch fixes a bug and is worth merging now.

I'm building a test kernel right now, assuming nothing blows up I'll
push this patch with the rest of the audit patches tomorrow; if
something bad happens, this is going to miss the first audit pull
request.

> diff --git a/kernel/audit.c b/kernel/audit.c
> index f20eee0..3bb4126 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -446,14 +446,19 @@ static void kauditd_retry_skb(struct sk_buff *skb)
>   * Description:
>   * Break the auditd/kauditd connection and move all the records in the retry
>   * queue into the hold queue in case auditd reconnects.
> + * The audit_cmd_mutex must be held when calling this function.
>   */

Don't resend, but in the future please start comments like this on the
previous line.
