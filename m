From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] fix creating/destroying the /proc/net/bonding dir
Date: Fri, 31 Oct 2003 11:34:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310311934.h9VJYMTs016412@death.ibm.com>
References: <amir.noam@intel.com>
Cc: jgarzik@pobox.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: Message from Amir Noam <amir.noam@intel.com>
   of "Thu, 23 Oct 2003 17:39:42 +0200." <200310231739.42556.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>This patch makes bonding create the /proc/net/bonding directory only
>if it exists (and destroy it only if it's empty).
>
>Synchronization with the NETDEV_CHANGENAME event is achieved through
>the RTNL semaphore.

	I've managed to break this running some scripts/programs to
simultaneously insmod/rmmod bonding, change the interface names, and
cat /proc/net/bonding/bondX files.  After the scripts run for a while,
the system ends up in a state where /proc/net/bonding/ is always
empty, no matter how many instances of bonding are loaded.

	Removing all instances of bonding also removes
/proc/net/bonding/ from /proc/net ("ls /proc/net" does not show it),
but "ls /proc/net/bonding" will succeed, showing an empty directory.
A subsequent insmod of bonding will create an always-empty
/proc/net/bonding (which again shows up in "ls /proc/net").  This
seems to be bad.

	I'm running this test on a 2 way 933, 640MB memory running
2.4.23-pre9 with the patch appiled.  I've reproduced this result twice
by running all three scripts simultaneously.  I haven't yet determined
what the problem is, but I'm presuming there's a race in the patched
code somewhere.  My test programs (3 scripts and a C program) are
appended.  When the "readproc-random" script stops printing "success"
messages, the error has occured.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

insmod-random.sh:
#!/bin/sh

isucc=0
rsucc=0
while /bin/true; do
	insert=${RANDOM};
	insert=`expr ${insert} % 2`
	num=${RANDOM};
	num=`expr ${num} % 10`;

	if [ ${insert} -eq 1 ]; then
		insmod -o bonding${num} bonding mode=0 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
		    isucc=`expr ${isucc} + 1`;
		    echo "insmod success " ${isucc};
		fi
	else
		rmmod bonding${num} > /dev/null 2>&1
		if [ $? -eq 0 ]; then
		    rsucc=`expr ${rsucc} + 1`;
		    echo "rmmod  success " ${rsucc};
		fi
	fi
done

readproc-random.sh:
#!/bin/sh

succ=0
while /bin/true; do
	num=`expr ${RANDOM} % 10`;

	cat /proc/net/bonding/bond${num} > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		succ=`expr ${succ} + 1`
		echo "success " ${succ};
	fi

done

sifname-random.sh:
#!/bin/sh

succ=0;
while /bin/true; do
	num1=`expr ${RANDOM} % 10`;
	num2=`expr ${RANDOM} % 10`;
	if [ ${num1} -eq ${num2} ]; then
		continue;
	fi

	./sifname bond${num1} bond${num2} > /dev/null 2>&1
	if [ $? -eq 0]; then
		succ=`expr ${succ} + 1`
		echo "success " ${succ};
	fi

done

sifname.c:
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <linux/sockios.h>
#include <sys/ioctl.h>

int
main(int argc, char **argv)
{
	int rv, s;
	struct ifreq ifr;

	if (argc != 3) {
		fprintf(stderr, "usage: %s oldifname newifname\n", argv[0]);
		exit(1);
	}

	s = socket(PF_INET, SOCK_STREAM, 0);
	if (-1 == s) {
		perror("socket");
		exit(1);
	}

	memset(&ifr, 0, sizeof(ifr));
	memmove(&ifr.ifr_name, argv[1], strlen(argv[1]));
	memmove(&ifr.ifr_newname, argv[2], strlen(argv[2]));

	rv = ioctl(s, SIOCSIFNAME, &ifr);
	if (-1 == rv) {
		perror("ioctl(SIOCSIFNAME)");
		exit(1);
	}

	return 0;
}
