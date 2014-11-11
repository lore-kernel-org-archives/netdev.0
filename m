From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2 07/19] selftests/firmware: add install target to enable
 installing test
Date: Tue, 11 Nov 2014 13:29:29 -0800
Message-ID: <CAGXu5j+yLqH0xj=5N90LRmK9F1xPLVWBy+cyUCzjvKJH7gE7AA@mail.gmail.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
	<1d2d13556ddbbbbb13989cdcb08447909bc4afaf.1415735831.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Phong Tran <tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	pranith kumar <bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	linux-kbuild <linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1d2d13556ddbbbbb13989cdcb08447909bc4afaf.1415735831.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry, I still really don't like this approach. While it is all in one
place (thank you for that), I think it isn't a form that is very
workable for the people maintaining the self tests. How about this,
instead of per-Makefile customization, why not define an execution
framework for these tests instead.

For example, how about every test directory must have a Makefile with
the needed binary targets. A common makefile could be included that
defines the "run_tests" target that calls the script "run_tests.sh"
that is a shell script in the current directory. (For inspiration, see
how kernel modules can be built out of tree.)

The "run_tests.sh" scripts could all include a common shell script,
say "../common.sh" that provides any common variables, functions, etc
(e.g. things like "Start $name test ..." should be in common.sh
instead of repeated in every script, the installation logic can be in
once place instead of repeated).

Then along side common.sh could be "run_installed_tests.sh" or
something, used on the installed target, that would traverse each
directory, etc. From this, we can have a much more data-driven
framework, and a common approach to running tests.

As such, we should declare up front how tests should behave on
failure. And the top-level test runner can do things like count the
number of tests, failures, etc.

Then, instead of splitting up the patches by test directory, you can
split them up by logical changes (e.g. defining the common "run_tests"
target, and then removing the target from all the tests by including
the common makefile stub that defines it).

-Kees

On Tue, Nov 11, 2014 at 12:27 PM, Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> wrote:
> Add a new make target to enable installing test. This target
> installs test in the kselftest install location and add to the
> kselftest script to run the test. Install target can be run
> only from top level source dir.
>
> Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> ---
>  tools/testing/selftests/firmware/Makefile | 49 ++++++++++++++++++++-----------
>  1 file changed, 32 insertions(+), 17 deletions(-)
>
> diff --git a/tools/testing/selftests/firmware/Makefile b/tools/testing/selftests/firmware/Makefile
> index e23cce0..2286dbb 100644
> --- a/tools/testing/selftests/firmware/Makefile
> +++ b/tools/testing/selftests/firmware/Makefile
> @@ -1,25 +1,40 @@
>  # Makefile for firmware loading selftests
>
>  # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
> +
> +__fw_filesystem:
> +fw_filesystem  = if /bin/sh ./fw_filesystem.sh ; then
> +fw_filesystem += echo fw_filesystem: ok;
> +fw_filesystem += else echo fw_filesystem: [FAIL];
> +fw_filesystem += fi
> +
> +__fw_userhelper:
> +fw_userhelper  = if /bin/sh ./fw_userhelper.sh ; then
> +fw_userhelper += echo fw_userhelper: ok;
> +fw_userhelper += else
> +fw_userhelper += echo fw_userhelper: [FAIL];
> +fw_userhelper += fi
> +
>  all:
>
> -fw_filesystem:
> -       @if /bin/sh ./fw_filesystem.sh ; then \
> -                echo "fw_filesystem: ok"; \
> -        else \
> -                echo "fw_filesystem: [FAIL]"; \
> -                exit 1; \
> -        fi
> -
> -fw_userhelper:
> -       @if /bin/sh ./fw_userhelper.sh ; then \
> -                echo "fw_userhelper: ok"; \
> -        else \
> -                echo "fw_userhelper: [FAIL]"; \
> -                exit 1; \
> -        fi
> -
> -run_tests: all fw_filesystem fw_userhelper
> +install:
> +ifdef INSTALL_KSFT_PATH
> +       install ./fw_filesystem.sh ./fw_userhelper.sh $(INSTALL_KSFT_PATH)
> +       @echo echo Start firmware filesystem test .... >> $(KSELFTEST)
> +       @echo "$(fw_filesystem)" >> $(KSELFTEST)
> +       @echo echo End firmware filesystem test .... >> $(KSELFTEST)
> +       @echo echo -------------------- >> $(KSELFTEST)
> +       @echo echo Start firmware userhelper test .... >> $(KSELFTEST)
> +       @echo "$(fw_userhelper)" >> $(KSELFTEST)
> +       @echo echo End firmware userhelper test .... >> $(KSELFTEST)
> +       @echo echo ============================== >> $(KSELFTEST)
> +else
> +       @echo Run make kselftest_install in top level source directory
> +endif
> +
> +run_tests:
> +       @$(fw_filesystem)
> +       @$(fw_userhelper)
>
>  # Nothing to clean up.
>  clean:
> --
> 1.9.1
>



-- 
Kees Cook
Chrome OS Security
