From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 16:55:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928145505.GH29961@sunbeam.de.gnumonks.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net> <20040927222613.GE3236@sunbeam.de.gnumonks.org> <20040927160636.7741d973.davem@davemloft.net> <1096327658.1729.19.camel@localhost.localdomain> <16729.9326.93269.422940@robur.slu.se> <20040928111906.GB29961@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uuKVzAmB+c+zQlhu"
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <20040928111906.GB29961@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uuKVzAmB+c+zQlhu
Content-Type: multipart/mixed; boundary="fU0UwhtRbpo05rnG"
Content-Disposition: inline


--fU0UwhtRbpo05rnG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Here goes some initial client code, so you can actually test the new
proc files from kernel.

As stated above, I'll continue working on this until it's somewhat
more feature-complete.

it's a multicall-binary so

rtstat		equals		lnstat -f rt_cache
ctstat		equals		lnstat -f ip_conntrack

I do not suggest inclusion of this current code into iproute2 at this
point, it's still under a lot of flux.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--fU0UwhtRbpo05rnG
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="lnstat.c"
Content-Transfer-Encoding: quoted-printable

/* lnstat.c:  Unified linux network statistics
 *
 * Copyright (C) 2004 by Harald Welte <laforge@gnumonks.org>
 *
 * Development of this code was funded by Astaro AG, http://www.astaro.com/
 *
 * Based on original concept and ideas from predecessor rtstat.c:
 *
 * Copyright 2001 by Robert Olsson <robert.olsson@its.uu.se>
 *                                 Uppsala University, Sweden
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <limits.h>
#include <time.h>
#include <getopt.h>

#include <sys/time.h>
#include <sys/types.h>


#define LNSTAT_VERSION "0.01 040928"

#define PROC_NET_STAT	"/proc/net/stat"

#define LNSTAT_MAX_FILES			32
#define LNSTAT_MAX_FIELDS_PER_LINE		32
#define LNSTAT_MAX_FIELD_NAME_LEN		32

struct lnstat_file;

struct lnstat_field {
	struct lnstat_file *file;
	unsigned int num;			/* field number in line */
	char name[LNSTAT_MAX_FIELD_NAME_LEN+1];
	unsigned long values[2];		/* two buffers for values */
};

struct lnstat_file {
	struct lnstat_file *next;
	char path[PATH_MAX+1];
	char basename[NAME_MAX+1];
	struct timeval last_read;		/* last time of read */
	struct timeval interval;		/* interval */
	FILE *fp;
	unsigned int num_fields;		/* number of fields */
	struct lnstat_field fields[LNSTAT_MAX_FIELDS_PER_LINE];
};



/* Read (and summarize for SMP) the different stats vars. */

static int scan_lines(struct lnstat_file *lf, int i)
{
	int j, num_lines =3D 0;

	for (j =3D 0; j < lf->num_fields; j++)
		lf->fields[j].values[i] =3D 0;

	while(!feof(lf->fp)) {
		#define FGETS_BUF_SIZE 512
		char buf[FGETS_BUF_SIZE];
		char *ptr =3D buf;

		num_lines++;

		fgets(buf, FGETS_BUF_SIZE-1, lf->fp);=20
		gettimeofday(&lf->last_read, NULL);

		for (j =3D 0; j < lf->num_fields; j++)
			lf->fields[j].values[i] +=3D strtoul(ptr, &ptr, 16);
	}
	return num_lines;
}

static int time_after(struct timeval *last,=20
		      struct timeval *tout,=20
		      struct timeval *now)
{
	if (now->tv_sec > last->tv_sec + tout->tv_sec)
		return 1;

	if (now->tv_sec =3D=3D last->tv_sec + tout->tv_sec) {
		if (now->tv_usec > last->tv_usec + tout->tv_usec)
			return 1;
	}

	return 0;
}

int lnstat_update(struct lnstat_file *lnstat_files,
		  void (*print_cb)(struct lnstat_file *, void *), void *v)
{
	struct lnstat_file *lf;
	char buf[FGETS_BUF_SIZE];
	struct timeval tv;

	/* FIXME: for more precision we need to move this into the loop */
	gettimeofday(&tv, NULL);

	for (lf =3D lnstat_files; lf; lf =3D lf->next) {
		if (time_after(&lf->last_read, &lf->interval, &tv)) {
			rewind(lf->fp);
			fgets(buf, FGETS_BUF_SIZE-1, lf->fp);
			scan_lines(lf, 1);

			(print_cb)(lf, v);

			rewind(lf->fp);
			fgets(buf, FGETS_BUF_SIZE-1, lf->fp);
			scan_lines(lf, 0);
		}
	}

	return 0;
}

/* scan first template line and fill in per-field data structures */
static int lnstat_scan_fields(struct lnstat_file *lf)
{
	char buf[FGETS_BUF_SIZE];
	char *tok;
	int i;

	rewind(lf->fp);
	fgets(buf, FGETS_BUF_SIZE-1, lf->fp);

	tok =3D strtok(buf, " \t\n");
	for (i =3D 0; i < LNSTAT_MAX_FIELDS_PER_LINE; i++) {
		lf->fields[i].file =3D lf;
		strncpy(lf->fields[i].name, tok, LNSTAT_MAX_FIELD_NAME_LEN);
		/* has to be null-terminate since we initialize to zero
		 * and field size is NAME_LEN + 1 */
		tok =3D strtok(NULL, " \t\n");
		if (!tok) {
			lf->num_fields =3D i+1;
			return 0;
		}
	}
	return 0;
}

/* find out whether string 'name; is in given string array */
static int name_in_array(const int num, const char **arr, const char *name)
{
	int i;
	for (i =3D 0; i < num; i++) {
		if (!strcmp(arr[i], name))
			return 1;
	}
	return 0;
}

/* allocate lnstat_file and open given file */
static struct lnstat_file *alloc_and_open(const char *path, const char *fil=
e)
{
	struct lnstat_file *lf;

	/* allocate */
	lf =3D malloc(sizeof(*lf));
	if (!lf)
		return NULL;

	/* initialize */
	memset(lf, 0, sizeof(*lf));

	/* de->d_name is guaranteed to be <=3D NAME_MAX */
	strcpy(lf->basename, file);
	strcpy(lf->path, path);
	strcat(lf->path, "/");
	strcat(lf->path, lf->basename);

	/* open */
	lf->fp =3D fopen(lf->path, "r");
	if (!lf->fp) {
		free(lf);
		return NULL;
	}

	return lf;
}


/* lnstat_scan_dir - find and parse all available statistics files/fields */
struct lnstat_file *lnstat_scan_dir(const char *path, const int num_req_fil=
es,
				    const char **req_files)
{
	DIR *dir;
	struct lnstat_file *lnstat_files =3D NULL;
	struct dirent *de;

	if (!path)
		path =3D PROC_NET_STAT;
=09
	dir =3D opendir(path);
	if (!dir)
		return NULL;

	while (de =3D readdir(dir)) {
		struct lnstat_file *lf;

		if (de->d_type !=3D DT_REG)
			continue;

		if (num_req_files && !name_in_array(num_req_files,
						    req_files, de->d_name))
			continue;

		lf =3D alloc_and_open(path, de->d_name);
		if (!lf)
			return NULL;

		/* fill in field structure */
		if (lnstat_scan_fields(lf) < 0)
			return NULL;

		/* prepend to global list */
		lf->next =3D lnstat_files;
		lnstat_files =3D lf;
	}
	closedir(dir);

	return lnstat_files;
}

int lnstat_dump(FILE *outfd, struct lnstat_file *lnstat_files)
{
	struct lnstat_file *lf;

	for (lf =3D lnstat_files; lf; lf =3D lf->next) {
		int i;

		fprintf(outfd, "%s:\n", lf->path);

		for (i =3D 0; i < lf->num_fields; i++)
			fprintf(outfd, "\t%2u: %s\n", i+1, lf->fields[i].name);

	}
	return 0;
}



static struct option opts[] =3D {
	{ "version", 0, NULL, 'V' },
	{ "help", 0, NULL, 'h' },
	{ "interval", 1, NULL, 'i' },
	{ "subject", 1, NULL, 's' },
	{ "file", 1, NULL, 'f' },
	{ "key", 1, NULL, 'k' },
};

static int usage(char *name, int exit_code)
{
	fprintf(stderr, "%s Version %s\n", name, LNSTAT_VERSION);
	fprintf(stderr, "Copyright (C) 2004 by Harald Welte "
			"<laforge@gnumonks.org>\n");
	fprintf(stderr, "This program is free software with ABSOLUTELY NO "
			"WARRANTY.\n\n");
	fprintf(stderr, "Parameters:\n");
	fprintf(stderr, "\t-h --help\t\tThis help message\n");
	fprintf(stderr, "\t-i --interval\t\tSet interval\n");
	fprintf(stderr, "\t-s --subject [0-2]\t?\n");=09
	fprintf(stderr, "\t-f --file\t\tStatistics file to use\n");=09
	fprintf(stderr, "\n");=09

	exit(exit_code);
}

static void print_cb(struct lnstat_file *lf, void *v)
{
	int i;
	int *interval =3D v;

	for (i =3D 0; i < lf->num_fields; i++) {
		unsigned long val =3D (lf->fields[i].values[1]
				    -lf->fields[i].values[0])/(*interval);
		fprintf(stdout, "%5lu ", val);
	}
	fputc('\n', stdout);
}


int main(int argc, char **argv)
{
	char *basename;
	int c, i =3D 1, interval =3D 2, hdr =3D 2;
	struct lnstat_file *lnstat_files;

	int num_req_files =3D 0, num_req_keys =3D 0;
	char *req_files[LNSTAT_MAX_FILES];
	char *req_keys[LNSTAT_MAX_FILES*LNSTAT_MAX_FIELDS_PER_LINE];
 =20
	/* backwards compatibility mode for old tools */
	basename =3D strrchr(argv[0], '/') + 1;
	if (!strcmp(basename, "rtstat")) {
		/* rtstat compatibility mode */
		req_files[0] =3D "rt_cache";
		num_req_files =3D 1;
	} else if (!strcmp(basename, "ctstat")) {
		/* ctstat compatibility mode */
		req_files[0] =3D "ip_conntrack";
		num_req_files =3D 1;
	}

	while ((c =3D getopt_long(argc, argv,"Vh?s:i:f:k:", opts, NULL)) !=3D -1)
		switch (c) {
			case '?':
			case 'h':      =20
				usage(argv[0], 0);
			case 'i':
				sscanf(optarg, "%u", &interval);
				break;
			case 's':
				sscanf(optarg, "%u", &hdr);
				break;
			case 'f':
				req_files[num_req_files++] =3D strdup(optarg);
				break;
			case 'k':
				req_keys[num_req_keys++] =3D strdup(optarg);
				break;
			default:
				usage(argv[0], 1);
		}

	if (interval < 1 )=20
		interval=3D1;

	lnstat_files =3D lnstat_scan_dir(PROC_NET_STAT, num_req_files,
				       req_files);

	lnstat_dump(stderr, lnstat_files);

	for (; 1; i++) {
#if 0
		if (hdr > 1 && (! (i % 20)))
			print_hdr_line();
#endif
		lnstat_update(lnstat_files, &print_cb, &interval);
		sleep(interval);
	}

	return 1;
}


--fU0UwhtRbpo05rnG--

--uuKVzAmB+c+zQlhu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWXtJXaXGVTD0i/8RAiJQAJ9Zfau0Ju3Mtkt0IYO+YYBMdlp0UACfcdXR
gCe+jopUPtxzHY1eaI35pNY=
=zDdd
-----END PGP SIGNATURE-----

--uuKVzAmB+c+zQlhu--
