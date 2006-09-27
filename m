From: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 11:50:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.44.0609271104470.9010-100000@dhcp09282.ntc.nokia.com>
References: <20060926183621.GX18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net,
	"Nordlund Kim (Nokia-NET/Helsinki)" <kim.nordlund@nokia.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext12.nokia.com ([131.228.20.171]:11363 "EHLO
	mgw-ext12.nokia.com") by vger.kernel.org with ESMTP
	id S1750882AbWI0IuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 04:50:12 -0400
To: Patrick McHardy <kaber@trash.net>, ext Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060926183621.GX18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 26 Sep 2006, ext Thomas Graf wrote:
> You're right, 0x80000000 - 1 is already positive. Ignore the patch.

basic_change() won't work without this patch if we compile the
kernel with the GCC version in RHEL5...

gcc version 4.1.1 20060817 (Red Hat 4.1.1-18)

which optimizes the code like this (objdump -S inttest.c) ...

int main()
{
   0:   55                      push   %ebp
   1:   89 e5                   mov    %esp,%ebp
  int i = 0x80000000;
  do {
    printf(KERN_ERR "in do %d\n", i);
   3:   68 00 00 00 80          push   $0x80000000
   8:   68 00 00 00 00          push   $0x0
   d:   e8 fc ff ff ff          call   e <main+0xe>
  } while (--i > 0);
  printf(KERN_ERR "out of do %d\n", i);
  12:   68 00 00 00 80          push   $0x80000000
  17:   68 0a 00 00 00          push   $0xa
  1c:   e8 fc ff ff ff          call   1d <main+0x1d>
  return 0;
}
  21:   31 c0                   xor    %eax,%eax
  23:   c9                      leave
  24:   c3                      ret

# ./inttest
in do -2147483648
out of do -2147483648

gcc -m32 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs 
-fno-strict-aliasing -fno-common -Wstrict-prototypes -Wundef 
-Werror-implicit-function-declaration  -fno-stack-protector -Os 
-fno-omit-frame-pointer -fno-optimize-sibling-calls 
-fasynchronous-unwind-tables -g -pipe -msoft-float 
-fno-builtin-sprintf -fno-builtin-log2 -fno-builtin-puts  
-mpreferred-stack-boundary=2  -march=i686 -mtune=generic 
-mtune=generic -mregparm=3 -ffreestanding 
-Wdeclaration-after-statement -Wno-pointer-sign   -c -o 
inttest.o inttest.c

So I would suggest to apply this patch to be compatible with the
GCC version in RHEL5, and simply to make code clearer (to the
intended idea).

--KimN


