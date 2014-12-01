From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH v2 03/19] selftests: add install target to enable installing
 selftests
Date: Mon, 01 Dec 2014 09:16:25 -0700
Message-ID: <547C9459.9000708@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <5e33b40696debde24fd04f6711e795a8860b7aee.1415735831.git.shuahkh@osg.samsung.com> <5476BA67.6020305@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Shuah Khan <shuahkh@osg.samsung.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5476BA67.6020305@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2014 10:45 PM, Masami Hiramatsu wrote:
> (2014/11/12 5:27), Shuah Khan wrote:
>> Add a new make target to enable installing selftests. This
>> new target will call install targets for the tests that are
>> specified in INSTALL_TARGETS. During install, a script is
>> generated to run tests that are installed. This script will
>> be installed in the selftest install directory. Individual
>> test Makefiles are changed to add to the script. This will
>> allow new tests to add install and run test commands to the
>> generated kselftest script. run_tests target runs the
>> generated kselftest script to run tests when it is initiated
>> from from "make kselftest" from top level source directory.
>>
>> Approach:
>>
>> make kselftest_target:
>> -- exports kselftest INSTALL_KSFT_PATH
>>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
>> -- exports path for ksefltest.sh
>> -- runs selftests make install target:
>>
>> selftests make install target
>> -- creates kselftest.sh script in install install dir
>> -- runs install targets for all INSTALL_TARGETS
>>    (Note: ftrace and powerpc aren't included in INSTALL_TARGETS,
>>           to not add more content to patch v1 series. This work
>>           will happen soon. In this series these two targets are
>>           run after running the generated kselftest script, without
>>           any regression in the way these tests are run with
>>           "make kselftest" prior to this work.)
>> -- install target can be run only from top level source dir.
>>
>> Individual test make install targets:
>> -- install test programs and/or scripts in install dir
>> -- append to the ksefltest.sh file to add commands to run test
>> -- install target can be run only from top level source dir.
>>
>> Adds the following new ways to initiate selftests:
>> -- Installing and running kselftest from install directory
>>    by running  "make kselftest"
>> -- Running kselftest script from install directory
>>
>> Maintains the following ways to run tests:
>> -- make -C tools/testing/selftests run_tests
>> -- make -C tools/testing/selftests TARGETS=target run_tests
>>    Ability specify targets: e.g TARGETS=net
>> -- make run_tests from tools/testing/selftests
>> -- make run_tests from individual test directories:
>>    e.g: make run_tests in tools/testing/selftests/breakpoints
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
>> ---
>>  tools/testing/selftests/Makefile | 31 ++++++++++++++++++++++++++++++-
>>  1 file changed, 30 insertions(+), 1 deletion(-)
>>
>> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
>> index 45f145c..b9bdc1d 100644
>> --- a/tools/testing/selftests/Makefile
>> +++ b/tools/testing/selftests/Makefile
>> @@ -16,6 +16,10 @@ TARGETS += sysctl
>>  TARGETS += firmware
>>  TARGETS += ftrace
>>  
>> +INSTALL_TARGETS = breakpoints cpu-hotplug efivarfs firmware ipc
>> +INSTALL_TARGETS += kcmp memfd memory-hotplug mqueue mount net
>> +INSTALL_TARGETS += ptrace sysctl timers user vm
>> +
>>  TARGETS_HOTPLUG = cpu-hotplug
>>  TARGETS_HOTPLUG += memory-hotplug
>>  
> 
> I think KSELFTEST itself should be defined here, since that is not
> a parameter.

I can do that.

> 
>> @@ -24,10 +28,35 @@ all:
>>  		make -C $$TARGET; \
>>  	done;
>>  
>> -run_tests: all
>> +install:
>> +ifdef INSTALL_KSFT_PATH
>> +	make all
>> +	@echo #!/bin/sh\n# Kselftest Run Tests .... >> $(KSELFTEST)
>> +	@echo # This file is generated during kselftest_install >> $(KSELFTEST)
>> +	@echo # Please don't change it !!\n  >> $(KSELFTEST)
>> +	@echo echo ============================== >> $(KSELFTEST)
>> +	for TARGET in $(INSTALL_TARGETS); do \
>> +		echo Installing $$TARGET; \
>> +		make -C $$TARGET install; \
> 
> Please pass O= option and others here.

I will change that.

> 
>> +	done;
>> +	chmod +x $(KSELFTEST)
>> +else
>> +	@echo Run make kselftest_install in top level source directory
>> +endif
>> +
>> +run_tests:
>> +ifdef INSTALL_KSFT_PATH
>> +	@cd $(INSTALL_KSFT_PATH); ./kselftest.sh; cd -
> 
> We'd better use some macro instead of ./kselftest.sh?
> 

I can play with this and see if there is a better way.

thanks,
-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
