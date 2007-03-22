From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take3 6/6][resend] add ioctls for adding/removing
 target
Date: Thu, 22 Mar 2007 19:05:40 +0900
Message-ID: <460254F4.8060800@bx.jp.nec.com>
References: <45FFCF31.3040000@bx.jp.nec.com> <45FFD4C1.7000103@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:40670 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934093AbXCVKFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 06:05:51 -0400
In-Reply-To: <45FFD4C1.7000103@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, I sent the incomplete sample program. 
So, I send the complete one again.
Any comments welcom.

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stropts.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <linux/netconsole.h>

#define NETCONSOLE_DEV_NAME "/dev/netconsole"
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

struct command {
	char *name;
	char *options;
	int (*handle_command)(struct command* command,
			      int argc, char* argv[]);
	void (*usage)(char *msg);
};

extern char *optarg;
extern int opterr, optind, errno;

static void generic_usage(char *msg) {
	fprintf(stderr, "Usage  : netconfig command [option] [args]\n");
	fprintf(stderr, "command: add remove help\n");
	exit(-1);
}

static int handle_command_add(struct command* command, int argc, char** argv)
{
	int i, fd, ch;
	unsigned int address;
	unsigned char mac[ETH_ALEN];
	struct netconsole_request req = {
		.netdev_name = "eth0",
		.local_port = 6665,
		.remote_port = 6666,
		.remote_mac = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF},
	};

	while ((ch = getopt(argc, argv, command->options)) != -1) {
		switch (ch) {
		case 'p':
			req.local_port = atoi(optarg);
			break;
		case 's':
			address = inet_addr(optarg);
			if (address == -1)
				(*command->usage)("invlid IP address!\n");
			req.local_ip = address;
			break;
		case 'h':
		default:
			(*command->usage)(NULL);
		}
	}
	argc -= optind;
	argv += optind;

	if (argc < 3 || argc > 4)
		(*command->usage)(NULL);

	memcpy(req.netdev_name, argv[0], IFNAMSIZ);
	address = inet_addr(argv[1]);
	if (address == -1)
		(*command->usage)("invlid IP address!\n");
	req.remote_ip = address;
	req.remote_port = atoi(argv[2]);
	if (argc == 4) {
		i = 0;
		mac[i++] = strtol(argv[3], NULL, 16);
		while ((argv[3] = strchr(argv[3], ':')) != NULL) {
			argv[3]++;
			mac[i++] = strtol(argv[3], NULL, 16);
		}
		if (i != ETH_ALEN)
			(*command->usage)("Invalid MAC address!\n");
		memcpy(req.remote_mac, mac, ETH_ALEN);
	}

	fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "cannot open device" NETCONSOLE_DEV_NAME "\n");
		return -1;
	}

	if(ioctl(fd, NETCON_ADD_TARGET, &req) != 0)
		perror("add");
	close(fd);

	return 0;
}

static void usage_add(char *msg)
{
	if (msg != NULL)
		fprintf(stderr, "%s", msg);
	fprintf(stderr, "Usage  : netconfig add [-options] dev_name remote_ip "
		"remote_port [remote_mac]\n");
	fprintf(stderr, "options:\n");
	fprintf(stderr, "        -p local_port     :local port number\n");
	fprintf(stderr, "        -s local_up       :local IP address\n");
	exit(-1);
}

static int handle_command_remove(struct command *command,
				 int argc, char** argv)
{
	int fd, id, ch;

	while ((ch = getopt(argc, argv, command->options)) != -1) {
		switch (ch) {
		case 'h':
		default:
			(*command->usage)(NULL);
		}
	}
	argc -= optind;
	argv += optind;

	if (argc != 1)
		(*command->usage)(NULL);

	id = atoi(argv[0]);
	fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "can't open device " NETCONSOLE_DEV_NAME "\n");
		return -1;
	}
	if(ioctl(fd, NETCON_REMOVE_TARGET, &id) != 0)
		perror("remove");
	close(fd);

	return 0;
}

static void usage_remove(char *msg) {
	fprintf(stderr, "Usage  : netconfig remove id\n");
	exit(-1);
}

static int handle_command_help(struct command *command,
			       int argc, char** argv) {
	(*command->usage)(NULL);

	return 0;
}

static void usage_help(char *msg) {
	generic_usage(NULL);
}

static struct command s_commands[] = {
	{"add", "hp:s:", handle_command_add, usage_add},
	{"remove", "hp:", handle_command_remove, usage_remove},
	{"help", NULL, handle_command_help, usage_help},
};

int main(int argc, char* argv[]) {
	int i;
	struct command *command = NULL;

	for(i = 0; i < ARRAY_SIZE(s_commands); i++) {
		if (argc <= 1)
			break;
		if (strcmp(s_commands[i].name, argv[1]) == 0) {
			command = &s_commands[i];
			break;
		}
	}

	if (command == NULL)
		generic_usage(NULL);
	argc--;
	argv++;

	if (command->handle_command)
		(*command->handle_command)(command, argc, argv);
	else {
		fprintf(stderr, "function handle_command() isn't set.");
		exit(-1);
	}
	return 0;
}



