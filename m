From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] format-security: move static strings to const
Date: Thu, 6 Apr 2017 20:21:54 -0700
Message-ID: <CAGXu5j+ms4KMy1Uh473r+2veTKnuHN4OuozS92WWwnycH-LGLw@mail.gmail.com>
References: <20170405214711.GA5711@beast> <87mvbtzztb.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>,
 linux-decnet-user@lists.sourceforge.net, Mugunthan V N <mugunthanvnm@ti.com>,
 Tony Lindgren <tony@atomide.com>, Viresh Kumar <viresh.kumar@linaro.org>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>,
 Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
 LKML <linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
 "Maciej W. Rozycki" <macro@linux-mips.org>,
 Christian Gromm <christian.gromm@microchip.com>,
 Daniel Vetter <daniel.vetter@intel.com>, Ingo Molnar <mingo@kernel.org>,
 devel@driverdev.osuosl.org, Kejian Yan <yankejian@huawei.com>,
 Felipe Balbi <felipe.balbi@linux.intel.com>,
 Russell King <linux@armlinux.org.uk>, Jarod Wilson <jarod@redhat.com>,
 David Airlie <airlied@linux.ie>, Daode Huang <huangdaode@hisilicon.com>,
 linux-serial@vger.kernel.org, Jiri Slaby <jslaby@suse.com>,
 Yisen Zhuang <yis
To: Jani Nikula <jani.nikula@linux.intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87mvbtzztb.fsf@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Apr 6, 2017 at 1:48 AM, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> On Thu, 06 Apr 2017, Kees Cook <keescook@chromium.org> wrote:
>> While examining output from trial builds with -Wformat-security enabled,
>> many strings were found that should be defined as "const", or as a char
>> array instead of char pointer. This makes some static analysis easier,
>> by producing fewer false positives.
>>
>> As these are all trivial changes, it seemed best to put them all in
>> a single patch rather than chopping them up per maintainer.
>
>> diff --git a/drivers/gpu/drm/drm_fb_helper.c b/drivers/gpu/drm/drm_fb_helper.c
>> index f6d4d9700734..1ff9d5912b83 100644
>> --- a/drivers/gpu/drm/drm_fb_helper.c
>> +++ b/drivers/gpu/drm/drm_fb_helper.c
>> @@ -2331,7 +2331,7 @@ EXPORT_SYMBOL(drm_fb_helper_hotplug_event);
>>  int __init drm_fb_helper_modinit(void)
>>  {
>>  #if defined(CONFIG_FRAMEBUFFER_CONSOLE_MODULE) && !defined(CONFIG_EXPERT)
>> -     const char *name = "fbcon";
>> +     const char name[] = "fbcon";
>
> I'd always write the former out of habit. Why should I start using the
> latter? What makes it better?

For me, it's mainly two reasons: sizeof() and -Wformat-security behavior.

The compiler treats "sizeof" differently. E.g. "sizeof(var)" shows the
allocation size for the array, and pointer size for the char pointer.
When doing things like snprintf(buf, sizeof(buf), ...) will do the
right thing, etc. (This is a poor example for a _const_ string, but
the point is that some calculations still work better with the array
over the pointer.)

The other situation (which is why I noted this to change them) is that
gcc's handling of them is different when faced with -Wformat-security
since it doesn't like to believe that const char pointers are actually
const for the purposes of being a format string.

> What keeps the kernel from accumulating tons more of the former?

Right now, nothing. The good news is that they're relatively rare, and
I notice them when they're added (since I have a -Wformat-security
tree). We could add a warning to checkpatch for suggesting const char
var[] over const char *var, perhaps?

> Here's an interesting comparison of the generated code. I'm a bit
> surprised by what gcc does, I would have expected no difference, like
> clang. https://godbolt.org/g/OdqUvN

Here's your example with sizeof() added, if you're curious...
https://godbolt.org/g/U1zIZK

> The other changes adding const in this patch are, of course, good.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
