From: "Artem S. Tashkinov" <t.artem@lycos.com>
Subject: Re: Re: Re: Re: Re: Re: A reliable kernel panic (3.6.2) and system
 crash when visiting a particular website
Date: Sun, 21 Oct 2012 19:49:01 +0000 (GMT)
Message-ID: <1906833625.122006.1350848941352.JavaMail.mail@webmail16>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121021002424.GA16247@liondog.tnic>
 <1798605268.19162.1350784641831.JavaMail.mail@webmail17>
 <20121021110851.GA6504@liondog.tnic>
 <121566322.100103.1350820776893.JavaMail.mail@webmail20>
 <20121021170315.GB20642@liondog.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org, zonque@gmail.com,
	alsa-devel@alsa-project.org, stern@rowland.harvard.edu
To: bp@alien8.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> On Oct 21, 2012, Borislav Petkov <bp@alien8.de> wrote: 
> 
> On Sun, Oct 21, 2012 at 11:59:36AM +0000, Artem S. Tashkinov wrote:
> > http://imageshack.us/a/img685/9452/panicz.jpg
> > 
> > list_del corruption. prev->next should be ... but was ...
> 
> Btw, this is one of the debug options I told you to enable.
> 
> > I cannot show you more as I have no serial console to use :( and the kernel
> > doesn't have enough time to push error messages to rsyslog and fsync
> > /var/log/messages
> 
> I already told you how to catch that oops: boot with "pause_on_oops=600"
> on the kernel command line and photograph the screen when the first oops
> happens. This'll show us where the problem begins.

This option didn't have any effect, or maybe it's because it's such a serious crash
the kernel has no time to actually print an ooops/panic message.

dmesg messages up to a crash can be seen here: https://bugzilla.kernel.org/attachment.cgi?id=84221

I dumped them using this application:

$ cat scat.c

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define O_LARGEFILE 0100000
#define BUFFER 4096
#define __USE_FILE_OFFSET64 1
#define __USE_LARGEFILE64 1

int main(int argc, char *argv[])
{
	int fd_out;
	int64_t bytes_read;
	void *buffer;

	if (argc!=2) {
		printf("Usage is: scat destination\n");
		return 1;
	}

	buffer = malloc(BUFFER * sizeof(char));
	if (buffer == NULL) {
		printf("Error: can't allocate buffers\n");
		return 2;		
	}
	memset(buffer, 0, BUFFER);

	printf("Dumping to \"%s\" ... ", argv[1]);
	fflush(NULL);

	if ((fd_out = open64(argv[1], O_WRONLY | O_LARGEFILE | O_SYNC | O_NOFOLLOW, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)) == -1) {
		printf("Error: destination file can't be created\n");
		perror("open() ");
		return 2;
	}

	bytes_read = 1;

	while (bytes_read) {
		bytes_read = fread(buffer, sizeof(char), BUFFER, stdin);

		if (write(fd_out, (void *) buffer, bytes_read) != bytes_read)
		{
			printf("Error: can't write data to the destination file! Possibly a target disk is full\n");
			return 3;
		}

	}

	close(fd_out);

	printf(" OK\n");
	return 0;
}


I ran it this way: while :; do dmesg -c; done | scat /dev/sda11 (yes, straight to a hdd partition to eliminate a FS cache)

Don't judge me harshly - I'm not a programmer.
