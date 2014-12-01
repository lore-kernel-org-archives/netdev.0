From: Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v2 02/19] kbuild: kselftest_install - add a new make target
 to install selftests
Date: Mon, 01 Dec 2014 16:47:13 +0100
Message-ID: <547C8D81.1030605@suse.cz>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014-11-11 21:27, Shuah Khan wrote:
> Add a new make target to install to install kernel selftests.
> This new target will build and install selftests. kselftest
> target now depends on kselftest_install and runs the generated
> kselftest script to reduce duplicate work and for common look
> and feel when running tests.
> 
> Approach:
> 
> make kselftest_target:
> -- exports kselftest INSTALL_KSFT_PATH
>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> -- exports path for ksefltest.sh
> -- runs selftests make install target:
> 
> selftests make install target
> -- creates kselftest.sh script in install install dir
> -- runs install targets for all INSTALL_TARGETS
>    (Note: ftrace and powerpc aren't included in INSTALL_TARGETS,
>           to not add more content to patch v1 series. This work
>           will happen soon. In this series these two targets are
>           run after running the generated kselftest script, without
>           any regression in the way these tests are run with
>           "make kselftest" prior to this work.)
> -- install target can be run only from top level source dir.
> 
> Individual test make install targets:
> -- install test programs and/or scripts in install dir
> -- append to the ksefltest.sh file to add commands to run test
> -- install target can be run only from top level source dir.
> 
> Adds the following new ways to initiate selftests:
> -- Installing and running kselftest from install directory
>    by running  "make kselftest"
> -- Running kselftest script from install directory
> 
> Maintains the following ways to run tests:
> -- make -C tools/testing/selftests run_tests
> -- make -C tools/testing/selftests TARGETS=target run_tests
>    Ability specify targets: e.g TARGETS=net
> -- make run_tests from tools/testing/selftests
> -- make run_tests from individual test directories:
>    e.g: make run_tests in tools/testing/selftests/breakpoints
> 
> Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> ---
>  Makefile | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index 05d67af..ccbd2e1 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1071,12 +1071,26 @@ headers_check: headers_install
>  	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi/asm $(hdr-dst) HDRCHECK=1
>  
>  # ---------------------------------------------------------------------------
> -# Kernel selftest
> +# Kernel selftest targets
> +
> +PHONY += __kselftest_configure
> +INSTALL_KSFT_PATH=$(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> +export INSTALL_KSFT_PATH
> +KSELFTEST=$(INSTALL_KSFT_PATH)/kselftest.sh
> +export KSELFTEST

Can this be moved to tools/testing/selftests/Makefile? It's only used in
this part of the tree.


>  PHONY += kselftest
> -kselftest:
> +kselftest: kselftest_install
>  	$(Q)$(MAKE) -C tools/testing/selftests run_tests
>  
> +# Kernel selftest install
> +
> +PHONY += kselftest_install
> +kselftest_install: __kselftest_configure
> +	@rm -rf $(INSTALL_KSFT_PATH)
> +	@mkdir -p $(INSTALL_KSFT_PATH)

Please use $(Q) insteaf od hardcoding the @.


> +	$(Q)$(MAKE) -C tools/testing/selftests install

The install target is only added by the next patch, which in turn
depends on changes done by later patches. The order (in the current
numbering) should be 01/19, 04/19, ... 19/19, 03/19 and 02/19.

Michal
