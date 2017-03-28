From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH v4 1/9] kasan: introduce helper functions for determining
 bug type
Date: Tue, 28 Mar 2017 16:03:30 +0200
Message-ID: <CAAeHK+zTfHp0dob9W5DtYZnpnrFTNxNDM45DA3Q2bTjZngpreg@mail.gmail.com>
References: <cover.1490383597.git.andreyknvl@google.com> <cover.1490709552.git.andreyknvl@google.com>
 <69485dff9439fca82343965d3746b52c36716d91.1490383597.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36124 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752147AbdC1ODo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:03:44 -0400
Received: by mail-pg0-f46.google.com with SMTP id g2so73069823pge.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:03:36 -0700 (PDT)
In-Reply-To: <69485dff9439fca82343965d3746b52c36716d91.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 4:00 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Introduce get_shadow_bug_type() function, which determines bug type
> based on the shadow value for a particular kernel address.
> Introduce get_wild_bug_type() function, which determines bug type
> for addresses which don't have a corresponding shadow value.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/kasan/report.c | 40 ++++++++++++++++++++++++++++++----------
>  1 file changed, 30 insertions(+), 10 deletions(-)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f479365530b6..e3af37b7a74c 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -49,7 +49,13 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
>         return first_bad_addr;
>  }
>
> -static void print_error_description(struct kasan_access_info *info)
> +static bool addr_has_shadow(struct kasan_access_info *info)
> +{
> +       return (info->access_addr >=
> +               kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
> +}
> +
> +static const char *get_shadow_bug_type(struct kasan_access_info *info)
>  {
>         const char *bug_type = "unknown-crash";
>         u8 *shadow_addr;
> @@ -96,6 +102,27 @@ static void print_error_description(struct kasan_access_info *info)
>                 break;
>         }
>
> +       return bug_type;
> +}
> +
> +static const char *get_wild_bug_type(struct kasan_access_info *info)
> +{
> +       const char *bug_type;
> +
> +       if ((unsigned long)info->access_addr < PAGE_SIZE)
> +               bug_type = "null-ptr-deref";
> +       else if ((unsigned long)info->access_addr < TASK_SIZE)
> +               bug_type = "user-memory-access";
> +       else
> +               bug_type = "wild-memory-access";
> +
> +       return bug_type;
> +}
> +
> +static void print_error_description(struct kasan_access_info *info)
> +{
> +       const char *bug_type = get_shadow_bug_type(info);
> +
>         pr_err("BUG: KASAN: %s in %pS at addr %p\n",
>                 bug_type, (void *)info->ip,
>                 info->access_addr);
> @@ -265,18 +292,11 @@ static void print_shadow_for_address(const void *addr)
>  static void kasan_report_error(struct kasan_access_info *info)
>  {
>         unsigned long flags;
> -       const char *bug_type;
>
>         kasan_start_report(&flags);
>
> -       if (info->access_addr <
> -                       kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
> -               if ((unsigned long)info->access_addr < PAGE_SIZE)
> -                       bug_type = "null-ptr-deref";
> -               else if ((unsigned long)info->access_addr < TASK_SIZE)
> -                       bug_type = "user-memory-access";
> -               else
> -                       bug_type = "wild-memory-access";
> +       if (!addr_has_shadow(info)) {
> +               const char *bug_type = get_wild_bug_type(info);
>                 pr_err("BUG: KASAN: %s on address %p\n",
>                         bug_type, info->access_addr);
>                 pr_err("%s of size %zu by task %s/%d\n",
> --
> 2.12.1.578.ge9c3154ca4-goog
>

Oops, accidently resent KASAN patchset together with AF_PACKET fixes.
Please ignore "[PATCH v4] kasan" patches.
