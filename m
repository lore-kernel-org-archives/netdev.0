From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v4 next 2/3] modules:capabilities: automatic module
 loading restriction
Date: Mon, 22 May 2017 15:28:32 -0700
Message-ID: <CAGXu5jL16KHWoddpT2tdnLrgrGM8vDxmTt=BSELf1Pqfquk3YA@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com> <1495454226-10027-3-git-send-email-tixxdz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andy Lutomirski <luto@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpark@posteo.
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1495454226-10027-3-git-send-email-tixxdz@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 4:57 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
> [...]
> diff --git a/kernel/module.c b/kernel/module.c
> index 4a3665f..ce7a146 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -282,6 +282,8 @@ module_param(sig_enforce, bool_enable_only, 0644);
>
>  /* Block module loading/unloading? */
>  int modules_disabled = 0;
> +int modules_autoload_mode = MODULES_AUTOLOAD_ALLOWED;
> +const int modules_autoload_max = MODULES_AUTOLOAD_DISABLED;
>  core_param(nomodule, modules_disabled, bint, 0);
>
>  /* Waiting for a module to finish initializing? */
> @@ -4296,6 +4298,46 @@ struct module *__module_text_address(unsigned long addr)
>  }
>  EXPORT_SYMBOL_GPL(__module_text_address);
>
> +/**
> + * may_autoload_module - Determine whether a module auto-load operation
> + * is permitted
> + * @kmod_name: The module name
> + * @allow_cap: if positive, may allow to auto-load the module if this capability
> + * is set
> + *
> + * Determine whether a module auto-load operation is allowed or not. The check
> + * uses the sysctl "modules_autoload_mode" value.
> + *
> + * This allows to have more control on automatic module loading, and align it
> + * with explicit load/unload module operations. The kernel contains several
> + * modules, some of them are not updated often and may contain bugs and
> + * vulnerabilities.
> + *
> + * The "allow_cap" is passed by callers to explicitly note that the module has
> + * the appropriate alias and that the "allow_cap" capability is set. This is
> + * for backward compatibility, the aim is to have a clear picture where:
> + *
> + * 1) Implicit module loading is allowed
> + * 2) Implicit module loading as with the explicit one requires CAP_SYS_MODULE.
> + * 3) Implicit module loading as with the explicit one can be disabled.
> + *
> + * Returns 0 if the module request is allowed or -EPERM if not.
> + */
> +int may_autoload_module(char *kmod_name, int allow_cap)
> +{
> +       if (modules_autoload_mode == MODULES_AUTOLOAD_ALLOWED)
> +               return 0;
> +       else if (modules_autoload_mode == MODULES_AUTOLOAD_PRIVILEGED) {
> +               /* Check CAP_SYS_MODULE then allow_cap if valid */
> +               if (capable(CAP_SYS_MODULE) ||
> +                   (allow_cap > 0 && capable(allow_cap)))

With the allow_cap check already happening in my suggestion for
__request_module(), it's not needed here. (In fact, it's not even
really needed to plumb this into the hook, I don't think?

Regardless, I remain a fan. :)

-Kees

-- 
Kees Cook
Pixel Security
