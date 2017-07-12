From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] igb: fix unused igb_deliver_wake_packet() warning when CONFIG_PM=n
Date: Wed, 12 Jul 2017 18:23:28 -0300
Message-ID: <CAOMZO5B1bFRJh3wjbR77HL4ZQ7LqmmSJdeVzRkbyJXUjFFCsrQ@mail.gmail.com>
References: <20170712210925.4F647FAA@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170712210925.4F647FAA@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2017 at 6:09 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> I'm seeing warnings on kernel configurations where CONFIG_PM is
> disabled.  It happens in 4.12, at least:
>
> drivers/ethernet/intel/igb/igb_main.c:7988:13: warning: 'igb_deliver_wake_packet' defined but not used [-Wunused-function]
>
> This is because igb_deliver_wake_packet() is defined outside of
> the #ifdef", but is used only a single time within the #ifdef in
> igb_resume().  Fix it by moving igb_deliver_wake_packet() next to
> igb_resume() inside the #ifdef.
>
> The diff ends up looking a bit funky here.  It *looks* like
> igb_suspend() is getting moved, but that's an artifact of how
> 'diff' sees the changes.
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Seems to be fixed by the following commit in linux-next:

commit 000ba1f2ebf0d6f93b9ae6cfbe5417e66f1b8e8c
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Thu Apr 27 21:09:52 2017 +0200

    igb: mark PM functions as __maybe_unused

    The new wake function is only used by the suspend/resume handlers that
    are defined in inside of an #ifdef, which can cause this harmless
    warning:

    drivers/net/ethernet/intel/igb/igb_main.c:7988:13: warning:
'igb_deliver_wake_packet' defined but not used [-Wunused-function]

    Removing the #ifdef, instead using a __maybe_unused annotation
    simplifies the code and avoids the warning.

    Fixes: b90fa8763560 ("igb: Enable reading of wake up packet")
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>
    Tested-by: Aaron Brown <aaron.f.brown@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
